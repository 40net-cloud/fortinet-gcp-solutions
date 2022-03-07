data "google_compute_subnetwork" "wrkld_subnet" {
  self_link = var.wrkld_subnet
}

data "google_compute_zones" "local" {
  region = data.google_compute_subnetwork.wrkld_subnet.region
  project = data.google_compute_subnetwork.wrkld_subnet.project
}

resource "random_string" "uniq" {
  length = 3
  special = false
  upper = false
}

resource "google_compute_instance" "websrv" {
  name = "wrkld-vm-${random_string.uniq.id}"
  machine_type = "e2-micro"
  zone = data.google_compute_zones.local.names[0]
  project = data.google_compute_subnetwork.wrkld_subnet.project

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    subnetwork = var.wrkld_subnet
  }

  metadata_startup_script = "apt update && apt install nginx -y"
}

output "network_ip" {
  value = google_compute_instance.websrv.network_interface[0].network_ip
}
