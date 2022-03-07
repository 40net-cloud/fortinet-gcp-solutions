data "google_compute_image" "fgt_image" {
  project = "fortigcp-project-001"
  family  = "fortigate-70-byol"
}

data "google_compute_subnetwork" "subnets" {
  count = length(var.subnets)
  name = var.subnets[count.index]
  region = var.region
}

data "google_compute_zones" "zones_in_region" {
  region         = var.region
}

data "google_compute_default_service_account" "default" {
}

locals {
  zones = [
    var.zones[0] != "" ? var.zones[0] : data.google_compute_zones.zones_in_region.names[0],
    var.zones[1] != "" ? var.zones[1] : data.google_compute_zones.zones_in_region.names[1]
  ]
}

locals {
  region_short   = replace( replace( replace( replace(var.region, "europe-", "eu"), "australia", "au" ), "northamerica", "na"), "southamerica", "sa")
  zones_short    = [
    replace( replace( replace( replace(local.zones[0], "europe-", "eu"), "australia", "au" ), "northamerica", "na"), "southamerica", "sa"),
    replace( replace( replace( replace(local.zones[1], "europe-", "eu"), "australia", "au" ), "northamerica", "na"), "southamerica", "sa")
  ]
}

resource "google_compute_disk" "logdisk" {
  count                  = 2

  name                   = "${var.prefix}disk-logdisk${count.index+1}-${local.zones_short[count.index]}"
  size                   = 30
  type                   = "pd-ssd"
  zone                   = local.zones[count.index]
}

resource "random_string" "api_key" {
  length                 = 30
  special                = false
  number                 = true
}

data "template_file" "configs" {
  count                  = 2
  template               = file("${path.module}/fgt-base-config.tpl")
  vars = {
    hostname             = "${var.prefix}vm${count.index+1}-${local.zones_short[count.index]}"
    unicast_peer_ip      = google_compute_address.hasync_priv[(count.index + 1) % 2 ].address
    unicast_peer_netmask = cidrnetmask(data.google_compute_subnetwork.subnets[2].ip_cidr_range)
    ha_prio              = (count.index+1)%2
    healthcheck_port     = var.healthcheck_port
    api_key              = random_string.api_key.result
    ext_ip               = google_compute_address.ext_priv[count.index].address
    ext_gw               = data.google_compute_subnetwork.subnets[0].gateway_address
    int_ip               = google_compute_address.int_priv[count.index].address
    int_gw               = data.google_compute_subnetwork.subnets[1].gateway_address
    int_cidr             = data.google_compute_subnetwork.subnets[0].ip_cidr_range
    hasync_ip            = google_compute_address.hasync_priv[count.index].address
    mgmt_ip              = google_compute_address.mgmt_priv[count.index].address
    mgmt_gw              = data.google_compute_subnetwork.subnets[3].gateway_address
    ilb_ip               = google_compute_address.ilb.address
  }
}

resource "google_compute_instance" "fgt-vm" {
  count                  = 2

  zone                   = local.zones[count.index]
  name                   = "${var.prefix}vm${count.index+1}-${local.zones_short[count.index]}"
  machine_type           = var.machine_type
  can_ip_forward         = true
  tags                   = ["fgt"]

  boot_disk {
    initialize_params {
      image              = data.google_compute_image.fgt_image.self_link
    }
  }
  attached_disk {
    source               = google_compute_disk.logdisk[count.index].name
  }

  service_account {
    email                = (var.service_account != "" ? var.service_account : data.google_compute_default_service_account.default.email)
    scopes               = ["cloud-platform"]
  }

  metadata = {
    user-data            = data.template_file.configs[count.index].rendered
    license              = fileexists(var.license_files[count.index]) ? file(var.license_files[count.index]) : null
  }

  network_interface {
    subnetwork           = data.google_compute_subnetwork.subnets[0].id
    network_ip           = google_compute_address.ext_priv[count.index].address
  }
  network_interface {
    subnetwork           = data.google_compute_subnetwork.subnets[1].id
    network_ip           = google_compute_address.int_priv[count.index].address
  }
  network_interface {
    subnetwork           = data.google_compute_subnetwork.subnets[2].id
    network_ip           = google_compute_address.hasync_priv[count.index].address
  }
  network_interface {
    subnetwork           = data.google_compute_subnetwork.subnets[3].id
    network_ip           = google_compute_address.mgmt_priv[count.index].address
    access_config {
      nat_ip             = google_compute_address.mgmt_pub[count.index].address
    }
  }
} //fgt-vm

# ILB resources
resource "google_compute_region_health_check" "health_check" {
  name                   = "${var.prefix}healthcheck-http${var.healthcheck_port}-${local.region_short}"
  region                 = var.region
  timeout_sec            = 2
  check_interval_sec     = 2

  http_health_check {
    port                 = var.healthcheck_port
  }
}

resource "google_compute_instance_group" "fgt-umigs" {
  count                  = 2

  name                   = "${var.prefix}umig${count.index}-${local.zones_short[count.index]}"
  zone                   = google_compute_instance.fgt-vm[count.index].zone
  instances              = [google_compute_instance.fgt-vm[count.index].self_link]
}

resource "google_compute_region_backend_service" "ilb_bes" {
  provider               = google-beta
  name                   = "${var.prefix}bes-ilb-trust-${local.region_short}"
  region                 = var.region
  network                = data.google_compute_subnetwork.subnets[1].network

  backend {
    group                = google_compute_instance_group.fgt-umigs[0].self_link
  }
  backend {
    group                = google_compute_instance_group.fgt-umigs[1].self_link
  }

  health_checks          = [google_compute_region_health_check.health_check.self_link]
  connection_tracking_policy {
    connection_persistence_on_unhealthy_backends = "NEVER_PERSIST"
  }
}

resource "google_compute_forwarding_rule" "ilb_fwd_rule" {
  name                   = "${var.prefix}fwdrule-ilb-trust-${local.region_short}"
  region                 = var.region
  network                = data.google_compute_subnetwork.subnets[1].network
  subnetwork             = data.google_compute_subnetwork.subnets[1].id
  ip_address             = google_compute_address.ilb.address
  all_ports              = true
  load_balancing_scheme  = "INTERNAL"
  backend_service        = google_compute_region_backend_service.ilb_bes.self_link
  allow_global_access    = true
}

# Firewall rules
resource "google_compute_firewall" "allow-mgmt" {
  name                   = "${var.prefix}fw-mgmt-allow-admin"
  network                = data.google_compute_subnetwork.subnets[3].network
  source_ranges          = var.admin_acl
  target_tags            = ["fgt"]

  allow {
    protocol             = "all"
  }
}

resource "google_compute_firewall" "allow-hasync" {
  name                   = "${var.prefix}fw-hasync-allow-fgt"
  network                = data.google_compute_subnetwork.subnets[2].network
  source_tags            = ["fgt"]
  target_tags            = ["fgt"]

  allow {
    protocol             = "all"
  }
}

resource "google_compute_firewall" "allow-port1" {
  name                   = "${var.prefix}fw-untrust-allowall"
  network                = data.google_compute_subnetwork.subnets[0].network
  source_ranges          = ["0.0.0.0/0"]

  allow {
    protocol             = "all"
  }
}

resource "google_compute_firewall" "allow-port2" {
  name                   = "${var.prefix}fw-trust-allowall"
  network                = data.google_compute_subnetwork.subnets[1].network
  source_ranges          = ["0.0.0.0/0"]

  allow {
    protocol             = "all"
  }
}

# Enable outbound connectivity via Cloud NAT
resource "google_compute_router" "nat_router" {
  name                   = "${var.prefix}cr-cloudnat-${local.region_short}"
  region                 = var.region
  network                = data.google_compute_subnetwork.subnets[0].network
}

resource "google_compute_router_nat" "cloud_nat" {
  name                      = "${var.prefix}nat-cloudnat-${local.region_short}"
  router                    = google_compute_router.nat_router.name
  region                    = var.region
  nat_ip_allocate_option    = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = data.google_compute_subnetwork.subnets[0].self_link
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

# OPTIONAL
/*
# Save api_key to Secret Manager
resource "google_secret_manager_secret" "api-secret" {
  secret_id              = "${var.prefix}-fgt-${local.region_short}-apikey"

  replication {
    automatic            = true
  }
}
resource "google_secret_manager_secret_version" "api_key" {
  secret                 = google_secret_manager_secret.api-secret.id
  secret_data            = random_string.api_key.id
}
*/
