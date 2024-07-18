resource "google_compute_instance" "cli" {
    name = "${var.prefix}-cloud-cli"
    zone = "${var.region}-b"
    machine_type = "e2-small"

    boot_disk {
      initialize_params {
        image = "ubuntu-os-cloud/ubuntu-2204-lts"
      }
    }
    network_interface {
      subnetwork = google_compute_subnetwork.intsrv.id
      access_config {}
    }
    tags = ["vpnclient"]
}

resource "google_compute_instance" "srv" {
    name = "${var.prefix}-remote-srv"
    zone = "${var.region}-b"
    machine_type = "e2-small"

    boot_disk {
      initialize_params {
        image = "ubuntu-os-cloud/ubuntu-2204-lts"
      }
    }
    network_interface {
      subnetwork = google_compute_subnetwork.remote.id
      network_ip = cidrhost(var.cidrs.remote, 2)
      access_config {}
    }
    tags = ["vpnclient"]
}