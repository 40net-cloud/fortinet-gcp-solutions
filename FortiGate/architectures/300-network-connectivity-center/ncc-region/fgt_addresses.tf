resource "google_compute_address" "mgmt_pub" {
  count                  = var.cluster_size

  region                 = var.region
  name                   = "${var.prefix}${var.indx}-addr-fgt${count.index+1}-mgmt"
}

resource "google_compute_address" "left" {
  count                  = var.cluster_size

  name                   = "${var.prefix}${var.indx}-addr-fgt${count.index+1}-${var.netname_left}"
  region                 = var.region
  address_type           = "INTERNAL"
  subnetwork             = google_compute_subnetwork.left.id
}

resource "google_compute_address" "right" {
  count                  = var.cluster_size

  name                   = "${var.prefix}${var.indx}-addr-fgt${count.index+1}-${var.netname_right}"
  region                 = var.region
  address_type           = "INTERNAL"
  subnetwork             = google_compute_subnetwork.right.id
}

resource "google_compute_address" "fgsp" {
  count                  = var.cluster_size

  name                   = "${var.prefix}${var.indx}-addr-fgt${count.index+1}-${var.netname_fgsp}"
  region                 = var.region
  address_type           = "INTERNAL"
  subnetwork             = google_compute_subnetwork.fgsp.id
}
