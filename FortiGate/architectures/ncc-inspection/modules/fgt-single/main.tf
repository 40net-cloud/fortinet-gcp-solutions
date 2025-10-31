data "google_compute_default_service_account" "default" {}
data "google_client_config" "default" {}

locals {
  # if service account is not passed explicitly in variable, pick the default Compute Engine account
  service_account = coalesce(var.service_account, data.google_compute_default_service_account.default.email)

  # If prefix is defined, add a "-" spacer after it
  prefix = length(var.prefix) > 0 && substr(var.prefix, -1, 1) != "-" ? "${var.prefix}-" : var.prefix

  # Get region from zone variable
  region = join("-", slice(split("-", var.zone), 0, 2))
}


#
# Create FortiGate instances with optional secondary logdisks and bootstrap configuration.
#

resource "google_compute_disk" "logdisk" {
  count = var.logdisk_size > 0 ? 1 : 0

  name   = "${local.prefix}disk-fgt-logdisk"
  size   = var.logdisk_size
  type   = "pd-ssd"
  zone   = var.zone
  labels = var.labels
}

data "cloudinit_config" "fgt_bootstrap" {
  gzip          = false
  base64_encode = false

  dynamic "part" {
    for_each = var.lic_flex_token == null ? [] : [1]
    content {
      filename     = "license"
      content_type = "text/plain; charset=\"us-ascii\""
      content      = <<-EOF
        LICENSE-TOKEN: ${var.lic_flex_token}
        EOF
    }
  }

  part {
    filename     = "config"
    content_type = "text/plain; charset=\"us-ascii\""
    content = templatefile("${path.module}/fgt-bootstrap.tftpl", {
      fgt_asn    = var.fgt_asn
      ncc_asn    = var.ncc_asn
      bgp_peers  = var.bgp_peers
      port2_gw   = var.subnet_ra.gateway_address
      port2_cidr = var.subnet_ra.ip_cidr_range
      port2_addr = var.address_ra
      port2_ilb  = google_compute_forwarding_rule.ilb.address
    })
  }

}

resource "google_compute_instance" "fgt_vm" {
  zone           = var.zone
  name           = "${local.prefix}vm"
  machine_type   = var.machine_type
  can_ip_forward = true
  tags           = var.fgt_tags
  labels         = var.labels

  boot_disk {
    initialize_params {
      image  = var.boot_image
      labels = var.labels
    }
  }
  dynamic "attached_disk" {
    for_each = google_compute_disk.logdisk[*].name
    content {
      source = attached_disk.value
    }
  }
  service_account {
    email  = local.service_account
    scopes = ["cloud-platform"]
  }
  metadata = {
    user-data          = data.cloudinit_config.fgt_bootstrap.rendered
    license            = var.lic_licfile_contents
    serial-port-enable = var.serial_port_enable
    oslogin-enable     = var.oslogin_enable
  }

  network_interface {
    subnetwork = var.subnet_mgmt.name
    network_ip = var.address_mgmt_priv
    access_config {
      nat_ip = var.address_mgmt_pub
    }
  }

  network_interface {
    subnetwork = var.subnet_ra.name
    network_ip = var.address_ra
  }
} //fgt-vm
