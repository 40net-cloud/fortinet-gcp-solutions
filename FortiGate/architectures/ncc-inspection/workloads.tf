
#
# Edge spokes
#

locals {
  spokes = {
    spoke1 = {
      ip_cidr_range = "10.10.201.0/24"
    },
    spoke2 = {
      ip_cidr_range = "10.10.202.0/24"
    }
  }
}

module "vpcspokes" {
  source   = "./modules/ncc-vpcspoke"
  for_each = local.spokes

  prefix                 = "${local.prefix}${each.key}"
  ip_cidr_range          = each.value.ip_cidr_range
  region                 = var.region
  ncc_hub_id             = google_network_connectivity_hub.hub.id
  ncc_group_id           = google_network_connectivity_group.edge.id
  default_route_next_hop = module.fgt.ilb_ip
}

#
# Workload VMs
#

resource "google_compute_instance" "cli1" {
  name         = "${local.prefix}cli1"
  zone         = "${var.region}-b"
  machine_type = "e2-medium"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    subnetwork = module.vpcspokes["spoke1"].subnet.name
  }
}
