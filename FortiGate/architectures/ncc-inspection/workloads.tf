#
# Workload VMs in spoke VPCs
#

resource "google_compute_instance" "cli1" {
  for_each = var.spokes

  name         = "${local.prefix}${each.key}-cli"
  zone         = "${coalesce(each.value.region, var.region)}-b"
  machine_type = "e2-small"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    subnetwork = one( module.net_edges[each.key].subnets_names )
    network_ip = cidrhost( each.value.ip_cidr_range, 10 )
  }
}
