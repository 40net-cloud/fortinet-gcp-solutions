resource "google_compute_address" "cr_nics_left" {
  count = 2

  name          = "${var.prefix}-addr-cr-${var.netname_left}-nic${count.index}"
  address_type  = "INTERNAL"
  subnetwork    = google_compute_subnetwork.left.self_link
  region        = var.region
}


resource "google_compute_router" "left" {
  name          = "${var.prefix}${var.indx}-cr-${var.netname_left}"
  network       = var.net_left.id
  region        = var.region
  bgp {
    asn               = var.asn_left_ncc
    advertise_mode    = "CUSTOM"
    advertised_groups = [
      "ALL_SUBNETS"
    ]
  }
}

output "left_cr" {
  value = google_compute_router.left
}

resource "google_network_connectivity_spoke" "left" {
  name          = "${var.prefix}${var.indx}-spoke-${var.netname_left}"
  location      = var.region
  hub           = var.hub.id

  linked_router_appliance_instances {
    dynamic "instances" {
      for_each                 = google_compute_instance.fgts
      content {
        virtual_machine        = instances.value.id
        ip_address             = instances.value.network_interface[0].network_ip
      }
    }
    site_to_site_data_transfer = true
  }
}

resource "google_compute_router_interface" "cr_nic0_left" {
  name = "nic0"
  router = google_compute_router.left.name
  region = var.region
  subnetwork = google_compute_subnetwork.left.self_link
  private_ip_address = google_compute_address.cr_nics_left[0].address
}
resource "google_compute_router_interface" "cr_nic1_left" {
  name = "nic1"
  router = google_compute_router.left.name
  region = var.region
  subnetwork = google_compute_subnetwork.left.self_link
  private_ip_address = google_compute_address.cr_nics_left[1].address
  redundant_interface = google_compute_router_interface.cr_nic0_left.name
}

resource "google_compute_router_peer" "left_nic0" {
  for_each = { for indx,vm in google_compute_instance.fgts : indx => vm }

  name                      = "nic0-fgt${each.key+1}"
  router                    = google_compute_router.left.name
  region                    = google_compute_router.left.region
  interface                 = google_compute_router_interface.cr_nic0_left.name
  peer_ip_address           = each.value.network_interface[0].network_ip
  peer_asn                  = var.asn_fgt
  router_appliance_instance = each.value.self_link

  depends_on = [
    google_network_connectivity_spoke.left
  ]
}
resource "google_compute_router_peer" "left_nic1" {
  for_each = { for indx,vm in google_compute_instance.fgts : indx => vm }

  name                      = "nic1-fgt${each.key+1}"
  router                    = google_compute_router.left.name
  region                    = google_compute_router.left.region
  interface                 = google_compute_router_interface.cr_nic1_left.name
  peer_ip_address           = each.value.network_interface[0].network_ip
  peer_asn                  = var.asn_fgt
  router_appliance_instance = each.value.self_link

  depends_on = [
    google_network_connectivity_spoke.left
  ]
}


################################################################################
#     RIGHT
################################################################################

resource "google_compute_address" "cr_nics_right" {
  count = 2

  name          = "${var.prefix}-addr-cr-${var.netname_right}-nic${count.index}"
  address_type  = "INTERNAL"
  subnetwork    = google_compute_subnetwork.right.self_link
  region        = var.region
}


resource "google_compute_router" "right" {
  name          = "${var.prefix}${var.indx}-cr-${var.netname_right}"
  network       = var.net_right.id
  region        = var.region
  bgp {
    asn               = var.asn_right_ncc
    advertise_mode    = "CUSTOM"
    advertised_groups = [
      "ALL_SUBNETS"
    ]
    dynamic "advertised_ip_ranges" {
      for_each = var.custom_ip_ranges
      content {
        range = advertised_ip_ranges.value
      }
    }
  }
}

resource "google_network_connectivity_spoke" "right" {
  name          = "${var.prefix}${var.indx}-spoke-${var.netname_right}"
  location      = var.region
  hub           = var.hub.id

  linked_router_appliance_instances {
    dynamic "instances" {
      for_each                 = google_compute_instance.fgts
      content {
        virtual_machine        = instances.value.id
        ip_address             = instances.value.network_interface[1].network_ip
      }
    }
    site_to_site_data_transfer = false
  }
}

resource "google_compute_router_interface" "cr_nic0_right" {
  name = "nic0"
  router = google_compute_router.right.name
  region = var.region
  subnetwork = google_compute_subnetwork.right.self_link
  private_ip_address = google_compute_address.cr_nics_right[0].address
}
resource "google_compute_router_interface" "cr_nic1_right" {
  name = "nic1"
  router = google_compute_router.right.name
  region = var.region
  subnetwork = google_compute_subnetwork.right.self_link
  private_ip_address = google_compute_address.cr_nics_right[1].address
  redundant_interface = google_compute_router_interface.cr_nic0_right.name
}

resource "google_compute_router_peer" "right_nic0" {
  for_each = { for indx,vm in google_compute_instance.fgts : indx => vm }

  name                      = "nic0-fgt${each.key+1}"
  router                    = google_compute_router.right.name
  region                    = google_compute_router.right.region
  interface                 = google_compute_router_interface.cr_nic0_right.name
  peer_ip_address           = each.value.network_interface[1].network_ip
  peer_asn                  = var.asn_fgt
  router_appliance_instance = each.value.self_link

  depends_on = [
    google_network_connectivity_spoke.right
  ]
}
resource "google_compute_router_peer" "right_nic1" {
  for_each = { for indx,vm in google_compute_instance.fgts : indx => vm }

  name                      = "nic1-fgt${each.key+1}"
  router                    = google_compute_router.right.name
  region                    = google_compute_router.right.region
  interface                 = google_compute_router_interface.cr_nic1_right.name
  peer_ip_address           = each.value.network_interface[1].network_ip
  peer_asn                  = var.asn_fgt
  router_appliance_instance = each.value.self_link

  depends_on = [
    google_network_connectivity_spoke.right
  ]
}
