resource "google_compute_network" "vpc" {
  name                            = "${var.prefix}vpc"
  auto_create_subnetworks         = false
  delete_default_routes_on_create = true
}

resource "google_compute_subnetwork" "sb" {
  name          = "${var.prefix}sb"
  network       = google_compute_network.vpc.id
  region        = var.region
  ip_cidr_range = var.ip_cidr_range
}

resource "google_network_connectivity_spoke" "this" {
  name     = "${var.prefix}ncc-spoke"
  location = "global"
  labels   = var.labels
  hub      = var.ncc_hub_id
  linked_vpc_network {
    uri = google_compute_network.vpc.self_link
    include_export_ranges = [
      "ALL_PRIVATE_IPV4_RANGES"
    ]
  }
  group = var.ncc_group_id
}

resource "google_compute_route" "via_fgt" {
  name         = "${var.prefix}default-via-fgt"
  network      = google_compute_network.vpc.name
  dest_range   = "0.0.0.0/0"
  next_hop_ilb = var.default_route_next_hop
}

resource "google_compute_firewall" "ssh" {
  name    = "${var.prefix}allow-ssh"
  network = google_compute_network.vpc.name

  source_ranges = [
    "0.0.0.0/0"
  ]

  allow {
    protocol = "TCP"
    ports    = ["22"]
  }
}
