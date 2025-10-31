resource "google_compute_instance_group" "umig" {
  name = "${local.prefix}ilb-umig"
  zone = var.zone
  instances = [
    google_compute_instance.fgt_vm.id
  ]
}

resource "google_compute_region_health_check" "ilb" {
  name   = "${local.prefix}ilb-health"
  region = local.region
  http_health_check {
    port = "8008"
  }
}

resource "google_compute_region_backend_service" "ilb" {
  name     = "${local.prefix}ilb-bes"
  region   = local.region
  network  = var.subnet_ra.network
  protocol = "UDP"
  backend {
    group          = google_compute_instance_group.umig.id
    balancing_mode = "CONNECTION"
  }
  health_checks = [
    google_compute_region_health_check.ilb.id
  ]
}

resource "google_compute_address" "ilb" {
  name         = "${local.prefix}ilb-addr"
  region       = local.region
  subnetwork   = var.subnet_ra.id
  address_type = "INTERNAL"
}

resource "google_compute_forwarding_rule" "ilb" {
  name                  = "${local.prefix}ilb-fwdrule"
  region                = local.region
  network               = var.subnet_ra.network
  subnetwork            = var.subnet_ra.id
  ip_protocol           = "UDP"
  all_ports             = true
  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.ilb.id
  ip_address            = google_compute_address.ilb.address
  allow_global_access   = true
}
