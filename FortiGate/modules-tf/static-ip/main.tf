# https://www.terraform.io/docs/providers/google/r/compute_address.html
# Create Static Cluster IP
resource "google_compute_address" "static" {
  name = "${var.name}-cluster-ip-${var.random_string}"
}
