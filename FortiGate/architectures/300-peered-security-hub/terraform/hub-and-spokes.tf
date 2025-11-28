module "hub_network" {
  source  = "terraform-google-modules/network/google"
  version = "~> 10.0"

  project_id   = local.project_id
  network_name = "${var.prefix}-hub"

  subnets = []
}

module "spoke_networks" {
  for_each = var.spokes

  source  = "terraform-google-modules/network/google"
  version = "~> 10.0"

  project_id   = local.project_id
  network_name = "${var.prefix}-${each.key}"

  subnets = [{
    subnet_name   = "${var.prefix}-${each.key}"
    subnet_ip     = each.value.ip_cidr_range
    subnet_region = each.value.region
    }
  ]

  ingress_rules = [
    {
      # Allow inbound SSH from IAP
      name          = "${var.prefix}-${each.key}-iap-ssh"
      source_ranges = ["35.235.240.0/20"]
      target_tags   = ["ssh"]
      allow = [{
        protocol = "TCP"
        ports    = ["22"]
      }]
    },
    # Open all inter-spoke communication
    {
      name          = "${var.prefix}-${each.key}-spoke2spoke"
      source_ranges = [for name, props in var.spokes : props.ip_cidr_range]
      allow = [{
        protocol = "all"
      }]
    }
  ]
}

resource "google_compute_network_peering" "hub_to_spokes" {
  for_each             = var.spokes
  name                 = "${var.prefix}-hub-to-${each.key}"
  network              = module.hub_network.network_id
  peer_network         = module.spoke_networks[each.key].network_id
  export_custom_routes = true
}

resource "google_compute_network_peering" "spokes-to-hub" {
  for_each             = var.spokes
  name                 = "${var.prefix}-${each.key}-to-hub"
  network              = module.spoke_networks[each.key].network_id
  peer_network         = module.hub_network.network_id
  import_custom_routes = true
}