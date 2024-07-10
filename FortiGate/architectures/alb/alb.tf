resource "google_compute_global_address" "alb" {
  name = "${var.prefix}-alb-eip"
}

resource "google_compute_health_check" "alb" {
  name = "${var.prefix}-alb-hc"
  tcp_health_check {
    port         = 8008
    proxy_header = "NONE"
  }
}

resource "google_compute_backend_service" "alb" {
  name                  = "${var.prefix}-alb-bes"
  health_checks         = [google_compute_health_check.alb.id]
  load_balancing_scheme = "EXTERNAL_MANAGED"
  protocol              = "HTTP"
  port_name             = "http"
  security_policy       = google_compute_security_policy.alb.id

  backend {
    group                 = module.fgt.fgt_umigs[0]
    balancing_mode        = "RATE"
    max_rate_per_instance = 99999
    capacity_scaler       = 1
  }
  backend {
    group                 = module.fgt.fgt_umigs[1]
    balancing_mode        = "RATE"
    max_rate_per_instance = 99999
    capacity_scaler       = 1
  }
}

resource "google_compute_url_map" "alb" {
  name            = "${var.prefix}-alb-urlmap"
  default_service = google_compute_backend_service.alb.id
}

resource "google_compute_url_map" "redirect" {
  name = "${var.prefix}-alb-redir-to-https"
  default_url_redirect {
    https_redirect = true
    strip_query = false
  }
}

resource "google_compute_target_http_proxy" "alb" {
  name    = "${var.prefix}-alb-proxy"
  url_map = google_compute_url_map.redirect.id
}

resource "google_compute_target_https_proxy" "alb" {
  name             = "${var.prefix}-alb-https"
  url_map          = google_compute_url_map.alb.id
  ssl_certificates = [google_compute_ssl_certificate.acme.id]
}

resource "google_compute_global_forwarding_rule" "alb" {
  name                  = "${var.prefix}-alb-frule"
  target                = google_compute_target_http_proxy.alb.id
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "80"
  ip_address            = google_compute_global_address.alb.id
}

resource "google_compute_global_forwarding_rule" "alb_https" {
  name                  = "${var.prefix}-alb-https"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "443"
  target                = google_compute_target_https_proxy.alb.id
  ip_address            = google_compute_global_address.alb.id
}

resource "google_compute_security_policy" "alb" {
  name = "${var.prefix}-policy"

  rule {
    action   = "deny(403)"
    priority = "1000"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["9.9.9.0/24"]
      }
    }
    description = "Deny access to IPs in 9.9.9.0/24"
  }

  rule {
    action   = "allow"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "default rule"
  }
}



# Self-signed regional SSL certificate for testing
resource "tls_private_key" "acme" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "acme" {
  private_key_pem = tls_private_key.acme.private_key_pem

  validity_period_hours = 24

  # Generate a new certificate if Terraform is run within three
  # hours of the certificate's expiration time.
  early_renewal_hours = 3

  # Reasonable set of uses for a server SSL certificate.
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]

  dns_names = ["acme.com"]

  subject {
    common_name  = "acme.com"
    organization = "ACME Examples, Inc"
  }
}

resource "google_compute_ssl_certificate" "acme" {
  name        = "${var.prefix}-acme-selfsigned"
  private_key = tls_private_key.acme.private_key_pem
  certificate = tls_self_signed_cert.acme.cert_pem
}




