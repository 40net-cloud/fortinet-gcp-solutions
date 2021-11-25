# Firewall Rules
# https://www.terraform.io/docs/providers/google/r/compute_firewall.html
resource "google_compute_firewall" "ingress" {
  count   = length(var.vpcs)
  name    = "${var.vpcs[count.index]}-ingress"
  network = var.vpcs[count.index]
  allow {
    protocol = var.allow_all
  }
  direction     = "INGRESS"
  source_ranges = var.source_ranges
}

resource "google_compute_firewall" "egress" {
  count   = length(var.vpcs)
  name    = "${var.vpcs[count.index]}-egress"
  network = var.vpcs[count.index]
  allow {
    protocol = var.allow_all
  }
  direction          = "EGRESS"
  destination_ranges = var.destination_ranges
}
