terraform {
  required_version = ">= 1.0.1"
  required_providers {
    google = {
      source = "hashicorp/google"
    }
    google-beta = {
      source = "hashicorp/google-beta"
    }
  }
}

resource "google_compute_subnetwork" "left" {
  name = "${var.prefix}-${var.netname_left}"
  region = var.region
  network = var.net_left.id
  ip_cidr_range = cidrsubnet( var.cidr_left, 4, var.indx )
}
resource "google_compute_subnetwork" "right" {
  name = "${var.prefix}-${var.netname_right}"
  region = var.region
  network = var.net_right.id
  ip_cidr_range = cidrsubnet( var.cidr_right, 4, var.indx )
}
resource "google_compute_subnetwork" "fgsp" {
  name = "${var.prefix}-${var.netname_fgsp}"
  region = var.region
  network = var.net_fgsp.id
  ip_cidr_range = cidrsubnet( var.cidr_fgsp, 4, var.indx )
}
