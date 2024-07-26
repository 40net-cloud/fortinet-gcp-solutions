# 
# Add HTTP load balancer if var.frontend_type == "http"
# 

resource "google_compute_health_check" "http" {
  count = var.frontend_type == "http" ? 1 : 0
  name  = "${local.prefix}http-hc"
  tcp_health_check {
    port = var.healthcheck_port
  }
}

resource "google_compute_backend_service" "http" {
  count                 = var.frontend_type == "http" ? 1 : 0
  name                  = "${local.prefix}http-bes-${local.region_short}"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  protocol              = "HTTP"
  port_name             = "http"
  health_checks = [
    google_compute_health_check.http[0].id
  ]

  backend {
    balancing_mode = "UTILIZATION"
    group          = google_compute_instance_group.fwb[0].id
  }
  backend {
    balancing_mode = "UTILIZATION"
    group          = google_compute_instance_group.fwb[1].id
  }
}

resource "google_compute_url_map" "http" {
  count           = var.frontend_type == "http" ? 1 : 0
  name            = "${local.prefix}http-urlmap"
  default_service = google_compute_backend_service.http[0].id
}

resource "google_compute_target_http_proxy" "http" {
  count   = var.frontend_type == "http" ? 1 : 0
  name    = "${local.prefix}http-proxy"
  url_map = google_compute_url_map.http[0].id
}

resource "google_compute_global_forwarding_rule" "fwb" {
  count                 = var.frontend_type == "http" ? 1 : 0
  name                  = "${local.prefix}http-alb"
  ip_protocol           = "TCP"
  port_range            = "80"
  target                = google_compute_target_http_proxy.http[0].id
  ip_address            = google_compute_global_address.alb[0].id
  load_balancing_scheme = "EXTERNAL_MANAGED"
}

resource "google_compute_global_address" "alb" {
  count = contains(["http", "https"], var.frontend_type) ? 1 : 0
  name  = "${local.prefix}eip"
}
