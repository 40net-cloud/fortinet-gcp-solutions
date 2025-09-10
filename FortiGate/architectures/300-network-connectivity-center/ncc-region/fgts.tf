data "google_compute_image" "fgt_image" {
  project = var.image_project
  family  = var.image_name == null ? var.image_family : null
  name    = var.image_name
}

data "google_compute_zones" "zones_in_region" {
  region = var.region
}

data "google_compute_default_service_account" "default" {
}

locals {
  zones = [
    var.zones[0] != "" ? var.zones[0] : data.google_compute_zones.zones_in_region.names[0],
    var.zones[1] != "" ? var.zones[1] : data.google_compute_zones.zones_in_region.names[1],
    var.zones[1] != "" ? var.zones[2] : data.google_compute_zones.zones_in_region.names[2]
  ]
}

# Create FortiGate instances with secondary logdisks and configuration. Everything 2 times (active + passive)
resource "google_compute_disk" "logdisk" {
  count = var.cluster_size

  name = "${var.prefix}${var.indx}disk-logdisk${count.index + 1}"
  size = var.logdisk_size
  type = "pd-ssd"
  zone = local.zones[count.index % length(local.zones)]
}



resource "google_compute_instance" "fgts" {
  count = var.cluster_size

  zone           = local.zones[count.index % length(local.zones)]
  name           = "${var.prefix}${var.indx}-fgt${count.index + 1}"
  machine_type   = var.machine_type
  can_ip_forward = true
  tags           = ["fgt"]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.fgt_image.self_link
    }
  }
  attached_disk {
    source = google_compute_disk.logdisk[count.index].name
  }

  service_account {
    email  = (var.service_account != "" ? var.service_account : data.google_compute_default_service_account.default.email)
    scopes = ["cloud-platform"]
  }

  metadata = {
    //    user-data            = (count.index == 0 ? local.config_active : local.config_passive )
    user-data = templatefile("${path.module}/base-config-flex.tpl", {
      hostname     = "fgt${count.index + 1}-${var.region}"
      flexvm_token = var.flex_tokens[count.index]
      ha_indx      = count.index
      ha_peers     = setsubtract(google_compute_address.fgsp[*].address, [google_compute_address.fgsp[count.index].address])
      my_asn       = var.asn_fgt
      left_asn     = var.asn_left_ncc
      right_asn    = var.asn_right_ncc
      left_nic0    = google_compute_address.cr_nics_left[0].address
      left_nic1    = google_compute_address.cr_nics_left[1].address
      right_nic0   = google_compute_address.cr_nics_right[0].address
      right_nic1   = google_compute_address.cr_nics_right[1].address
      right_subnet = google_compute_subnetwork.right.ip_cidr_range
      right_gw     = google_compute_subnetwork.right.gateway_address
      fgt_config   = ""
    })
    serial-port-enable = true
  }

  network_interface {
    subnetwork = google_compute_subnetwork.left.id
    network_ip = google_compute_address.left[count.index].address
    access_config {
      nat_ip = google_compute_address.mgmt_pub[count.index].address
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.right.id
    network_ip = google_compute_address.right[count.index].address
  }
  network_interface {
    subnetwork = google_compute_subnetwork.fgsp.id
    network_ip = google_compute_address.fgsp[count.index].address
  }

} //fgt-vm
