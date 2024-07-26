# 
# Add network load balancer reesources if var.frontend_type == "nlb"
# 

resource "google_compute_region_health_check" "nlb" {
  count = var.frontend_type == "nlb" ? 1 : 0

  name   = "${local.prefix}nlb-hc-tcp80-${local.region_short}"
  region = local.region
  tcp_health_check {
    port = var.healthcheck_port
  }
}

resource "google_compute_region_backend_service" "nlb" {
  count = var.frontend_type == "nlb" ? 1 : 0

  name                  = "${local.prefix}nlb-bes-${local.region_short}"
  load_balancing_scheme = "EXTERNAL"
  protocol              = "TCP"
  region                = local.region

  health_checks = [
    google_compute_region_health_check.nlb[0].id
  ]

  backend {
    group = google_compute_instance_group.fwb[0].id
  }
  backend {
    group = google_compute_instance_group.fwb[1].id
  }
}

resource "google_compute_forwarding_rule" "nlb" {
  count = var.frontend_type == "nlb" ? 1 : 0

  name                  = "${local.prefix}nlb-fr"
  region                = local.region
  ip_address            = google_compute_address.nlb[0].address
  ip_protocol           = "TCP"
  ports                 = ["80", "443"]
  load_balancing_scheme = "EXTERNAL"
  backend_service       = google_compute_region_backend_service.nlb[0].self_link
}


resource "google_compute_address" "nlb" {
  count        = var.frontend_type == "nlb" ? 1 : 0
  name         = "${local.prefix}eip"
  address_type = "EXTERNAL"
  region       = local.region
}