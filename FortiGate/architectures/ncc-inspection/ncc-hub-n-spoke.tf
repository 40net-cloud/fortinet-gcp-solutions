#
# Build the NCC non-network resources
#

resource "google_network_connectivity_hub" "hub" {
  name            = "${local.prefix}ncchub"
  labels          = var.labels
  preset_topology = "STAR"
}

resource "google_network_connectivity_group" "center" {
  hub    = google_network_connectivity_hub.hub.id
  name   = "center"
  labels = var.labels
  auto_accept {
    auto_accept_projects = [
      local.project_id
    ]
  }
}

resource "google_network_connectivity_group" "edge" {
  hub    = google_network_connectivity_hub.hub.id
  name   = "edge"
  labels = var.labels
  auto_accept {
    auto_accept_projects = [
      local.project_id
    ]
  }
}

#
# Create and connect the "hub" VPC
# 

module "net_center" {
  source  = "terraform-google-modules/network/google"
  version = "12.0.0"

  project_id              = local.project_id
  network_name            = "${local.prefix}vpc-hub"
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"

  subnets = [{
    subnet_name   = "${local.prefix}sb-raspoke"
    subnet_region = var.region
    subnet_ip     = "10.10.100.0/24"
  }]

  ingress_rules = [{
    name          = "${local.prefix}fw-raspoke-allowall"
    priority      = 200
    source_ranges = ["0.0.0.0/0"]
    allow = [{
      protocol = "all"
    }]
  }]
}

resource "google_network_connectivity_spoke" "center" {
  name     = "${local.prefix}center"
  location = "global"
  hub      = google_network_connectivity_hub.hub.id
  group    = google_network_connectivity_group.center.id
  linked_vpc_network {
    uri = module.net_center.network_id
  }
}

#
# Edge spokes
# VPC names and CIDRs are packed in a local variable and looped over for clarity
#
module "net_edges" {
  source   = "terraform-google-modules/network/google"
  version  = "12.0.0"
  for_each = var.spokes

  project_id              = local.project_id
  network_name            = "${local.prefix}${each.key}"
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"

  subnets = [{
    subnet_name   = "${local.prefix}${each.key}-sb"
    subnet_region = coalesce( each.value.region, var.region)
    subnet_ip     = each.value.ip_cidr_range
  }]

  ingress_rules = [{
    name          = "${local.prefix}${each.key}-allowall"
    priority      = 200
    source_ranges = ["0.0.0.0/0"]
    allow = [{
      protocol = "all"
    }]
  }]
}

resource "google_network_connectivity_spoke" "edges" {
  for_each = var.spokes

  name     = "${var.prefix}${each.key}"
  location = "global"
  labels   = var.labels
  hub      = google_network_connectivity_hub.hub.id
  linked_vpc_network {
    uri = module.net_edges[each.key].network_id
    include_export_ranges = [
      "ALL_PRIVATE_IPV4_RANGES"
    ]
  }
  group = google_network_connectivity_group.edge.id
}
