# Compute Engine Instance - Active
resource "google_compute_instance" "active_instance" {
  name           = "${var.name}-ha-active-instance-${var.random_string}"
  machine_type   = var.machine
  zone           = var.zone
  can_ip_forward = "true"
  tags           = ["ha-instance"]

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  # Public Network
  network_interface {
    network    = var.public_vpc_network
    subnetwork = var.public_subnet
    access_config {
      nat_ip = var.static_ip
    }
  }

  # Private Network
  network_interface {
    network    = var.private_vpc_network
    subnetwork = var.private_subnet
  }

  # HA Sync Network
  network_interface {
    network    = var.sync_vpc_network
    subnetwork = var.sync_subnet
  }

  # Mgmt Network
  network_interface {
    network    = var.mgmt_vpc_network
    subnetwork = var.mgmt_subnet
    access_config {
    }
  }

  # Metadata which will deploy the license and configure the HA
  metadata = {
    user-data = "${data.template_file.setup-active-instance.rendered}"
    license   = file(var.license_file) # Placeholder for the license file for BYOL image, Need to fetch the License File
  }

  # Service Account scope for the GCP SDN Connector
  service_account {
    email  = var.service_account
    scopes = ["cloud-platform"]
  }

  // When Changing the machine_type, min_cpu_platform, service_account, or enable display on an instance requires stopping it
  allow_stopping_for_update = true
}

# Compute Engine Instance - Passive
resource "google_compute_instance" "passive_instance" {
  name           = "${var.name}-ha-passive-instance-${var.random_string}"
  machine_type   = var.machine
  zone           = var.zone
  can_ip_forward = "true"
  tags           = ["ha-instance"]

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  # Public Network
  network_interface {
    network    = var.public_vpc_network
    subnetwork = var.public_subnet
  }

  # Private Network
  network_interface {
    network    = var.private_vpc_network
    subnetwork = var.private_subnet
  }

  # HA Sync Network
  network_interface {
    network    = var.sync_vpc_network
    subnetwork = var.sync_subnet
  }

  # Mgmt Network
  network_interface {
    network    = var.mgmt_vpc_network
    subnetwork = var.mgmt_subnet
    access_config {
    }
  }

  # Metadata which will deploy the license and configure the HA
  metadata = {
    user-data = "${data.template_file.setup-passive-instance.rendered}"
    license   = file(var.license_file_2) # Placeholder for the license file for BYOL image, Need to fetch the License File
  }

  # Service Account scope for the GCP SDN Connector
  service_account {
    email  = var.service_account
    scopes = ["cloud-platform"]
  }

  // When Changing the machine_type, min_cpu_platform, service_account, or enable display on an instance requires stopping it
  allow_stopping_for_update = true

  depends_on = [google_compute_instance.active_instance]
}
