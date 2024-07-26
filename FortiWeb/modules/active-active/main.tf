terraform {
  required_version = ">= 1.2.0" #postconditions
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}

#
# Pull default zones and the service account. Both can be overridden in variables if needed.
#
data "google_compute_zones" "zones_in_region" {
  count  = var.region != null ? 1 : 0
  region = local.region
}

data "google_compute_default_service_account" "default" {}

data "google_client_config" "default" {}

# Pull information about subnets we will connect to FortiGate instances. Subnets must
# already exist (can be created in parent module).
data "google_compute_subnetwork" "connected" {
  for_each = toset([for indx in range(length(var.subnets)) : "port${indx + 1}"])
  name     = var.subnets[substr(each.value, 4, 1) - 1]
  region   = local.region
}

locals {
  # Pick explicit or detected zones and save to locals
  zones = [
    var.zones[0] != "" ? var.zones[0] : data.google_compute_zones.zones_in_region[0].names[0],
    var.zones[1] != "" ? var.zones[1] : data.google_compute_zones.zones_in_region[0].names[1]
  ]

  # derive region from zones if provided, otherwise use the region from variable, as last resort use default region from provider
  region = coalesce(try(join("-", slice(split("-", var.zones[0]), 0, 2)), null), var.region, data.google_client_config.default.region)
}

# We'll use shortened region and zone names for some resource names. This is a standard shortening described in
# GCP security foundations.
locals {
  region_short = replace(replace(replace(replace(replace(replace(replace(replace(replace(local.region, "-south", "s"), "-east", "e"), "-central", "c"), "-north", "n"), "-west", "w"), "europe", "eu"), "australia", "au"), "northamerica", "na"), "southamerica", "sa")
  zones_short = [for zone in local.zones :
    "${local.region_short}${substr(zone, length(local.region) + 1, 1)}"
  ]

  # If prefix is defined, add a "-" spacer after it
  prefix      = length(var.prefix) > 0 && substr(var.prefix, -1, 1) != "-" ? "${var.prefix}-" : var.prefix
  public_nics = ["port1"] #hard code for this release
}

resource "google_compute_address" "prv" {
  for_each = toset([for pair in setproduct(
    ["fwb1", "fwb2"],
    [for netindx in range(length(var.subnets)) : "port${netindx + 1}"]
  ) : join("-", pair)])

  name         = "${local.prefix}addr-${each.value}"
  region       = local.region
  address_type = "INTERNAL"
  subnetwork   = data.google_compute_subnetwork.connected[split("-", each.value)[1]].id
}

resource "google_compute_address" "pub" {
  #for_each = toset(local.public_nics)
  for_each = toset([for pair in setproduct(
    ["fwb1", "fwb2"],
    local.public_nics
  ) : join("-", pair)])

  name         = "${local.prefix}eip-${each.value}"
  region       = local.region
  address_type = "EXTERNAL"
}

#
# Find image based on version+lic...
#
module "fwbimage" {
  count  = var.image.name == "" ? 1 : 0
  source = "./modules/fwb-get-image"

  ver = var.image.version
  lic = "${try(var.license_files[0], "")}${try(var.flex_tokens[0], "")}" != "" ? "byol" : var.image.license
}
# ... or based on name+project
data "google_compute_image" "custom" {
  count   = var.image.name != "" ? 1 : 0
  filter  = "name eq ${var.image.name}"
  project = var.image.project
}

#
# Deploy the VMs
# 
resource "google_compute_instance" "fwb" {
  count = 2

  name         = "${local.prefix}vm-fwb${count.index + 1}"
  machine_type = var.machine_type
  zone         = local.zones[count.index]
  tags         = var.tags
  labels       = var.labels

  boot_disk {
    initialize_params {
      image  = var.image.name == "" ? module.fwbimage[0].self_link : data.google_compute_image.custom[0].self_link
      labels = var.labels
    }
  }

  service_account {
    email  = (var.service_account != "" ? var.service_account : data.google_compute_default_service_account.default.email)
    scopes = ["cloud-platform"]
  }

  dynamic "network_interface" {
    for_each = [for netindx in range(length(var.subnets)) : "port${netindx + 1}"]

    content {
      subnetwork = data.google_compute_subnetwork.connected[network_interface.value].name
      network_ip = google_compute_address.prv["fwb${count.index + 1}-${network_interface.value}"].address
      dynamic "access_config" {
        for_each = contains(local.public_nics, network_interface.value) ? [1] : []
        content {
          nat_ip = google_compute_address.pub["fwb${count.index + 1}-${network_interface.value}"].address
        }
      }
    }
  }

  metadata = {
    fortiweb_user_password = var.admin_password
    flex_token             = try(var.flex_tokens[count.index], null)
    license                = try(var.license_files[count.index], null)
    user-data = templatefile("${path.module}/fwb_config.tftpl", {
      hostname      = "${local.prefix}fwb${count.index + 1}"
      ha_prio       = count.index + 1
      ha_local      = google_compute_address.prv["fwb${count.index + 1}-${var.ha_port}"].address
      ha_peer       = google_compute_address.prv["fwb${(count.index + 1) % 2 + 1}-${var.ha_port}"].address
      admin_sport   = var.admin_port
      custom_config = var.fwb_config
      vip           = var.frontend_type == "nlb" ? google_compute_address.nlb[0].address : ""
      vip_name      = var.frontend_type == "nlb" ? google_compute_address.nlb[0].name : ""
    })
  }

  lifecycle {
    postcondition {
      condition     = !(("${try(var.license_files[0], "")}${try(var.flex_tokens[0], "")}" != "") && strcontains(self.boot_disk[0].initialize_params[0].image, "payg"))
      error_message = "You provided a FortiWeb BYOL (or Flex) license, but you're attempting to deploy a PAYG image. This would result in a double license fee."
    }
  }
}

#
# Prepare the unmanaged instance groups for the load balancers
#
resource "google_compute_instance_group" "fwb" {
  count = 2

  name = "${local.prefix}umig-${local.zones_short[count.index]}"
  zone = local.zones[count.index]
  named_port {
    name = "http"
    port = "80"
  }
  instances = matchkeys(
    google_compute_instance.fwb[*].self_link,
    google_compute_instance.fwb[*].zone,
    [local.zones[count.index]]
  )
}