#
# This file creates the optional NCC RA spoke, Cloud Router and BGP peerings 
# It will be used just so the FortiGates automatically learn routes to all NCC networks
# 

resource "google_network_connectivity_spoke" "ra" {
  name     = "${local.prefix}ncc-spoke-fgt"
  location = var.region
  labels   = var.labels
  hub      = google_network_connectivity_hub.hub.id
  group    = google_network_connectivity_group.center.id
  linked_router_appliance_instances {
    dynamic "instances" {
      for_each = { 
        fgt1: module.fgt_ha.fgts[0]
        fgt2: module.fgt_ha.fgts[1]
      }
      content {
        virtual_machine = instances.value.self_link
        ip_address = instances.value.ports["port2"].network_ip
      }
    }
    site_to_site_data_transfer = false
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
  count = 2
  name                      = "nic0-fgt${count.index+1}"
  router                    = google_compute_router.ra.name
  region                    = google_compute_router.ra.region
  interface                 = google_compute_router_interface.ra_nic0.name
  peer_ip_address           = module.fgt_ha.fgts[count.index].network_interface[1].network_ip
  peer_asn                  = var.fgt_asn
  router_appliance_instance = module.fgt_ha.fgts[count.index].self_link

  depends_on = [
    google_network_connectivity_spoke.ra
  ]
}

resource "google_compute_router_peer" "ra_nic1" {
  count = 2
  name                      = "nic1-fgt${count.index+1}"
  router                    = google_compute_router.ra.name
  region                    = google_compute_router.ra.region
  interface                 = google_compute_router_interface.ra_nic1.name
  peer_ip_address           = module.fgt_ha.fgts[count.index].network_interface[1].network_ip
  peer_asn                  = var.fgt_asn
  router_appliance_instance = module.fgt_ha.fgts[count.index].self_link

  depends_on = [
    google_network_connectivity_spoke.ra
  ]
}





