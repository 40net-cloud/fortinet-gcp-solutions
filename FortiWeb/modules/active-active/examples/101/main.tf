terraform {
  required_providers {
    fortiflexvm = {
      version = "2.3.2"
      source  = "fortinetdev/fortiflexvm"
    }
  }
}


#
# Deploy the module
# 
module "fwbaa" {
  source      = "../.."
  subnets     = [
    google_compute_subnetwork.ext.name,
    google_compute_subnetwork.int.name
  ]
  region      = var.region
  prefix      = var.prefix
  flex_tokens = fortiflexvm_entitlements_vm_token.fwb[*].token
  image = {
    version = "7.4"
  }
  frontend_type         = "https"
  https_certificate_url = google_compute_ssl_certificate.acme.id
  fwb_config = templatefile("./fwb_custom_config.tftpl", {
    server_addr   = google_compute_address.itworks.address
    server_subnet = google_compute_subnetwork.psc.ip_cidr_range
    port2_gw      = google_compute_subnetwork.int.gateway_address
  })

  depends_on = [ 
    google_compute_subnetwork.ext,
    google_compute_subnetwork.int
   ]
}

#
# Create dedicated demo VPC networks, subnets and firewalls
# 
resource "google_compute_network" "ext" {
  name                    = "${var.prefix}-external"
  auto_create_subnetworks = false
}

resource "google_compute_network" "int" {
  name                    = "${var.prefix}-internal"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "ext" {
  name          = "${var.prefix}-sb-external"
  network       = google_compute_network.ext.id
  ip_cidr_range = "10.10.1.0/24"
  region        = var.region
}

resource "google_compute_subnetwork" "int" {
  name          = "${var.prefix}-sb-internal"
  network       = google_compute_network.int.id
  ip_cidr_range = "10.10.2.0/24"
  region        = var.region
}

resource "google_compute_firewall" "admin" {
  name = "${var.prefix}-admin"
  network = google_compute_network.ext.id
  source_ranges = [ "0.0.0.0/0" ]
  allow {
    protocol = "TCP"
    ports = [ "22", "8443" ]
  }
}

resource "google_compute_firewall" "data" {
  name = "${var.prefix}-data"
  network = google_compute_network.ext.id
  source_ranges = [ "130.211.0.0/22", "35.191.0.0/16" ]
  allow {
    protocol = "TCP"
    ports = [ "80", "443" ]
  }
}

resource "google_compute_firewall" "data_int" {
  name = "${var.prefix}-data-int"
  network = google_compute_network.int.id
  source_ranges = [ google_compute_subnetwork.int.ip_cidr_range ]
  allow {
    protocol = "TCP"
    ports = ["80"]
  }
}

# 
# Create subnet for PSC endpoint (must be in europe-west6)
# 
resource "google_compute_subnetwork" "psc" {
  name          = "${var.prefix}-sb-psc"
  network       = google_compute_network.int.id
  region        = "europe-west6"
  ip_cidr_range = "10.10.200.0/24"
}

#
# Create PSC endpoint
# 
resource "google_compute_address" "itworks" {
  name         = "${var.prefix}-itworks-endpoint"
  region       = google_compute_subnetwork.psc.region
  subnetwork   = google_compute_subnetwork.psc.id
  address_type = "INTERNAL"
}

resource "google_compute_forwarding_rule" "itworks" {
  name                    = "itworks"
  region                  = google_compute_subnetwork.psc.region
  ip_address              = google_compute_address.itworks.id
  network                 = google_compute_network.int.id
  target                  = "https://www.googleapis.com/compute/v1/projects/forti-emea-se/regions/europe-west6/serviceAttachments/bm-itworks-psc"
  allow_psc_global_access = true
  load_balancing_scheme   = ""
}

/*
resource "google_compute_instance" "wrk1" {
  name         = "${var.prefix}-wrk1"
  machine_type = "e2-medium"
  zone         = "us-central1-b"
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }
  network_interface {
    subnetwork = data.google_compute_subnetwork.internal.self_link
  }
  tags = ["allow-iap-ssh"]
}

resource "google_compute_firewall" "ssh" {
    name = "${var.prefix}-tmp-ssh"
    network = data.google_compute_subnetwork.internal.network
    source_ranges = ["0.0.0.0/0"]
    allow {
      protocol = "TCP"
      ports = ["22"]
    }
}
*/
