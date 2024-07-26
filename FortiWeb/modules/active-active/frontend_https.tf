# 
# Add HTTPS load balancer resources and HTTP->HTTPS redirect if var.frontend_type == "https"
# 

resource "google_compute_health_check" "https" {
  count = var.frontend_type == "https" ? 1 : 0
  name  = "${local.prefix}https-hc"
  tcp_health_check {
    port = var.healthcheck_port
  }
}

resource "google_compute_backend_service" "https" {
  count                 = var.frontend_type == "https" ? 1 : 0
  name                  = "${local.prefix}https-bes-${local.region_short}"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  protocol              = "HTTP"
  port_name             = "http"
  health_checks = [
    google_compute_health_check.https[0].id
  ]

  backend {
    balancing_mode = "UTILIZATION"
    group          = google_compute_instance_group.fwb[0].id
  }
  backend {
    balancing_mode = "UTILIZATION"
    group          = google_compute_instance_group.fwb[1].id
  }

  lifecycle {
    precondition {
      condition     = (var.frontend_type == "https" && var.https_certificate_url != "") || contains(["nlb", "http"], var.frontend_type)
      error_message = "For the frontend_type \"https\" you must upload your HTTPS certificate to GCP and provide its URL."
    }
  }
}

resource "google_compute_url_map" "https" {
  count           = var.frontend_type == "https" ? 1 : 0
  name            = "${local.prefix}http-urlmap"
  default_service = google_compute_backend_service.https[0].id
}

resource "google_compute_url_map" "redirect" {
  count = var.frontend_type == "https" ? 1 : 0
  name  = "${local.prefix}redir-to-https"
  default_url_redirect {
    https_redirect = true
    strip_query    = false
  }
}

resource "google_compute_target_https_proxy" "https" {
  count            = var.frontend_type == "https" ? 1 : 0
  name             = "${local.prefix}https-proxy"
  url_map          = google_compute_url_map.https[0].id
  ssl_certificates = [var.https_certificate_url]
}

resource "google_compute_global_forwarding_rule" "https" {
  count                 = var.frontend_type == "https" ? 1 : 0
  name                  = "${local.prefix}https-alb"
  ip_protocol           = "TCP"
  port_range            = "443"
  target                = google_compute_target_https_proxy.https[0].id
  ip_address            = google_compute_global_address.alb[0].id
  load_balancing_scheme = "EXTERNAL_MANAGED"
}

resource "google_compute_target_http_proxy" "redirect" {
  count   = var.frontend_type == "https" ? 1 : 0
  name    = "${var.prefix}redir-to-https"
  url_map = google_compute_url_map.redirect[0].id
}

resource "google_compute_global_forwarding_rule" "redirect" {
  count                 = var.frontend_type == "https" ? 1 : 0
  name                  = "${local.prefix}redir-to-https"
  ip_protocol           = "TCP"
  port_range            = "80"
  target                = google_compute_target_http_proxy.redirect[0].id
  ip_address            = google_compute_global_address.alb[0].id
  load_balancing_scheme = "EXTERNAL_MANAGED"
}