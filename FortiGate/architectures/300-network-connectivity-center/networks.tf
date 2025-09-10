resource "google_compute_network" "left" {
  name = "${var.prefix}-${var.netname_left}"
  auto_create_subnetworks = false
  routing_mode = "GLOBAL"
}
resource "google_compute_network" "right" {
  name = "${var.prefix}-${var.netname_right}"
  auto_create_subnetworks = false
  routing_mode = "GLOBAL"
}
resource "google_compute_network" "fgsp" {
  name = "${var.prefix}-${var.netname_fgsp}"
  auto_create_subnetworks = false
  routing_mode = "GLOBAL"
}

resource "google_compute_firewall" "left_allowall" {
  name = "${var.prefix}-fw-${var.netname_left}-allowall"
  network = google_compute_network.left.self_link
  allow {
    protocol = "all"
  }
  source_ranges = ["0.0.0.0/0"]
}
resource "google_compute_firewall" "right_allowall" {
  name = "${var.prefix}-fw-${var.netname_right}-allowall"
  network = google_compute_network.right.self_link
  allow {
    protocol = "all"
  }
  source_ranges = ["0.0.0.0/0"]
}
resource "google_compute_firewall" "fgsp_allowall" {
  name = "${var.prefix}-fw-${var.netname_fgsp}-allowall"
  network = google_compute_network.fgsp.self_link
  allow {
    protocol = "all"
  }
  source_tags = ["fgt"]
}
