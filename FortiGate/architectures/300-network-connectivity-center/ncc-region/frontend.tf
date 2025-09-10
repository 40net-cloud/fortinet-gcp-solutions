resource "google_compute_instance_group" "front" {
  count = var.cluster_size
  zone = local.zones[count.index % length(local.zones)]

  name = "${var.prefix}-front-umig"
  instances = [
    google_compute_instance.fgts[count.index].id
  ]
}

resource "google_compute_region_health_check" "front" {
  name = "${var.prefix}-front-hc"
  region = var.region

  http_health_check {
    port = 8008
  }
}

resource "google_compute_region_backend_service" "front" {
  provider = google-beta
  name = "${var.prefix}-front-bes"
  region = var.region

  health_checks = [google_compute_region_health_check.front.id]
  load_balancing_scheme = "EXTERNAL"
  protocol = "UNSPECIFIED"

  dynamic "backend" {
    for_each = google_compute_instance_group.front[*].id
    content {
      group = backend.value
    }
  }
}

resource "google_compute_address" "front" {
  name = "${var.prefix}-front-demo"
  region = var.region
  address_type = "EXTERNAL"
}

resource "google_compute_forwarding_rule" "front" {
  name = "${var.prefix}-front-fw"
  region = var.region
  ip_address = google_compute_address.front.address
  ip_protocol = "L3_DEFAULT"
  all_ports = true
  load_balancing_scheme = "EXTERNAL"
  backend_service = google_compute_region_backend_service.front.id
}

output "frontend_eip" {
  value = google_compute_address.front.address
}
