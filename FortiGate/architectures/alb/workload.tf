resource "google_compute_address" "srv" {
  name = "${var.prefix}-srv-ip"
  region = var.region
  subnetwork = google_compute_subnetwork.nets[var.net_names[1]].id
  address_type = "INTERNAL"
}

resource "google_compute_instance" "srv" {
  name         = "${var.prefix}-testvm"
  machine_type = "e2-micro"
  zone         = "${var.region}-b"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.nets[var.net_names[1]].id
    network_ip = google_compute_address.srv.address
  }

  metadata_startup_script = <<EOF
    apt update
    apt install nginx -y
  EOF

  depends_on = [ module.fgt ]
}