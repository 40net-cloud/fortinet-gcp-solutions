
# Pull information about subnets we will connect to FortiGate instances. Subnets must
# already exist (can be created in parent module).
data "google_compute_subnetwork" "subnets" {
  count  = length(var.subnets)
  name   = var.subnets[count.index]
  region = local.region
}

data "google_compute_default_service_account" "default" {}

data "google_compute_subnetwork" "connected" {
  for_each = toset([for indx in range(length(var.subnets)) : "port${indx + 1}"]) #toset(var.subnets)
  name     = var.subnets[substr(each.value, 4, 1) - 1]
  region   = local.region
}

locals {
  zone   = var.zone # != "" ? var.zone : data.google_compute_zones.zones_in_region.names[0]
  region = substr(local.zone, 0, length(local.zone) - 2)
}

# We'll use shortened region and zone names for some resource names. This is a standard shortening described in
# GCP security foundations.
locals {
  region_short = replace(replace(replace(replace(local.region, "europe-", "eu"), "australia", "au"), "northamerica", "na"), "southamerica", "sa")
  zone_short   = replace(replace(replace(replace(local.zone, "europe-", "eu"), "australia", "au"), "northamerica", "na"), "southamerica", "sa")

  # If prefix is defined, add a "-" spacer after it
  prefix      = length(var.prefix) > 0 && substr(var.prefix, -1, 1) != "-" ? "${var.prefix}-" : var.prefix
  public_nics = ["port1"]
}

resource "google_compute_address" "prv" {
  for_each = toset([for indx in range(length(var.subnets)) : "port${indx + 1}"])

  name         = "${local.prefix}addr-${each.value}"
  region       = local.region
  address_type = "INTERNAL"
  subnetwork   = data.google_compute_subnetwork.connected[each.value].id
}

resource "google_compute_address" "pub" {
  for_each = toset(local.public_nics)

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
  lic = "${try(var.license, "")}${try(var.flex_token, "")}" != "" ? "byol" : var.image.license
}
# ... or based on name+project
data "google_compute_image" "custom" {
  count   = var.image.name != "" ? 1 : 0
  filter  = "name eq ${var.image.name}"
  project = var.image.project
}
locals {
  fwb_image = var.image.name == "" ? module.fwbimage[0].self_link : data.google_compute_image.custom[0].self_link
}

resource "google_compute_instance" "fwb" {
  name         = "${local.prefix}vm-fwb"
  machine_type = var.machine_type
  zone         = local.zone
  tags         = var.tags
  labels       = var.labels

  boot_disk {
    initialize_params {
      image  = local.fwb_image
      labels = var.labels
    }
  }

  service_account {
    email  = (var.service_account != "" ? var.service_account : data.google_compute_default_service_account.default.email)
    scopes = ["cloud-platform"]
  }

  dynamic "network_interface" {
    for_each = [for indx in range(length(var.subnets)) : "port${indx + 1}"]

    content {
      subnetwork = data.google_compute_subnetwork.connected[network_interface.value].name
      #nic_type   = local.nic_type
      network_ip = google_compute_address.prv[network_interface.value].address
      dynamic "access_config" {
        for_each = contains(local.public_nics, network_interface.value) ? [1] : []
        content {
          nat_ip = google_compute_address.pub[network_interface.value].address
        }
      }
    }
  }

  metadata = {
    # fortiweb_user_password = ""
    flex_token = var.flex_token
    license    = var.license
    user-data  = var.config
  }

  lifecycle {
    precondition {
      condition     = contains(split("-", local.fwb_image), "byol") || coalesce(var.flex_token, var.license, "payg") == "payg"
      error_message = "You provided a FortiWeb BYOL (or Flex) license, but you're attempting to deploy a PAYG image. This would result in a double license fee."
    }
  }
}