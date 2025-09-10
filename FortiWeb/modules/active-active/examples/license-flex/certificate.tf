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