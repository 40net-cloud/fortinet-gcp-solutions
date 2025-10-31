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

resource "google_network_connectivity_spoke" "ra" {
  name     = "${local.prefix}ncc-spoke-fgt"
  location = var.region
  labels   = var.labels
  hub      = google_network_connectivity_hub.hub.id
  group    = google_network_connectivity_group.center.id
  linked_router_appliance_instances {
    instances {
      virtual_machine = module.fgt.self_link
      ip_address      = google_compute_address.fgt_ra.address
    }
    site_to_site_data_transfer = true
    include_import_ranges      = ["ALL_IPV4_RANGES"]
  }
}

resource "google_compute_router" "ra" {
  name    = "${local.prefix}cr-ra"
  network = module.net_center.network_id
  region  = var.region
  bgp {
    asn            = var.ncc_asn
    advertise_mode = "CUSTOM"
    advertised_groups = [
      "ALL_SUBNETS"
    ]
  }
}

resource "google_compute_address" "cr_ra_nics" {
  count = 2

  name         = "${local.prefix}cr-raspoke-nic${count.index}"
  address_type = "INTERNAL"
  region       = var.region
  subnetwork   = module.net_center.subnets["${var.region}/${local.prefix}sb-raspoke"].self_link
}

resource "google_compute_router_interface" "ra_nic0" {
  name               = "nic0"
  router             = google_compute_router.ra.name
  region             = var.region
  subnetwork         = module.net_center.subnets["${var.region}/${local.prefix}sb-raspoke"].self_link
  private_ip_address = google_compute_address.cr_ra_nics[0].address
}

resource "google_compute_router_interface" "ra_nic1" {
  name                = "nic1"
  router              = google_compute_router.ra.name
  region              = var.region
  subnetwork          = module.net_center.subnets["${var.region}/${local.prefix}sb-raspoke"].self_link
  private_ip_address  = google_compute_address.cr_ra_nics[1].address
  redundant_interface = google_compute_router_interface.ra_nic0.name
}

resource "google_compute_router_peer" "ra_nic0" {
  name                      = "nic0-fgt"
  router                    = google_compute_router.ra.name
  region                    = google_compute_router.ra.region
  interface                 = google_compute_router_interface.ra_nic0.name
  peer_ip_address           = google_compute_address.fgt_ra.address
  peer_asn                  = var.fgt_asn
  router_appliance_instance = module.fgt.self_link

  depends_on = [
    google_network_connectivity_spoke.ra
  ]
}

resource "google_compute_router_peer" "ra_nic1" {
  name                      = "nic1-fgt"
  router                    = google_compute_router.ra.name
  region                    = google_compute_router.ra.region
  interface                 = google_compute_router_interface.ra_nic1.name
  peer_ip_address           = google_compute_address.fgt_ra.address
  peer_asn                  = var.fgt_asn
  router_appliance_instance = module.fgt.self_link

  depends_on = [
    google_network_connectivity_spoke.ra
  ]
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



