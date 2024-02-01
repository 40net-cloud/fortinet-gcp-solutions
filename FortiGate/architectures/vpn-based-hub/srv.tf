resource "google_compute_instance" "srv1" {
  name         = "${var.prefix}-srv1"
  machine_type = "e2-medium"
  zone         = "${var.region}-b"
  boot_disk {
    initialize_params {
      image  = "ubuntu-os-cloud/ubuntu-2204-lts"
      labels = var.labels
    }
  }
  network_interface {
    subnetwork = module.networks["spoke1"].subnets_ids[0]
    access_config {}
  }
  tags = ["spoke1"]
  metadata_startup_script = "apt update && apt install nginx -y"
}

resource "google_compute_instance" "srv2" {
  name         = "${var.prefix}-srv2"
  machine_type = "e2-medium"
  zone         = "${var.region}-b"
  boot_disk {
    initialize_params {
      image  = "ubuntu-os-cloud/ubuntu-2204-lts"
      labels = var.labels
    }
  }
  network_interface {
    subnetwork = module.networks["spoke2"].subnets_ids[0]
    access_config {}
  }
  tags = ["spoke2"]
  metadata_startup_script = <<EOT
  apt update && apt install nginx -y
  wget "https://www.eicar.org/download/eicar-com/?wpdmdl=8840&refresh=65b77894dc5b41706522772" -O /var/www/html/eicar.com
  EOT
}
