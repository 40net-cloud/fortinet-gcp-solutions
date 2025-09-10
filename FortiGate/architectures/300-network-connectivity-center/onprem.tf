/*  This file adds on-prem network with 4 VPN tunnels faking Interconnect
 *  You will get 4 tunnels, 4 BGP peers, 2 additional NCC spokes in 2 regions.
 *
 *  NOTE: deploying this will fail if your regions don't support site-to-site NCC.
 */


resource "google_compute_network" "onprem" {
  name = "${var.prefix}-onprem"
  auto_create_subnetworks = false
  routing_mode = "GLOBAL"
}

resource "google_compute_subnetwork" "onprem1" {
  name = "${var.prefix}-onprem1"
  region = var.regions[0]
  network = google_compute_network.onprem.id
  ip_cidr_range = "192.168.100.0/24"
}
resource "google_compute_subnetwork" "onprem2" {
  name = "${var.prefix}-onprem2"
  region = var.regions[1]
  network = google_compute_network.onprem.id
  ip_cidr_range = "192.168.200.0/24"
}

################################################################################

resource "google_compute_ha_vpn_gateway" "onprem1" {
  region = var.regions[0]
  name = "${var.prefix}-havpn-onprem1"
  network = google_compute_network.onprem.id
}

resource "google_compute_ha_vpn_gateway" "onprem2" {
  region = var.regions[1]
  name = "${var.prefix}-havpn-onprem2"
  network = google_compute_network.onprem.id
}

resource "google_compute_ha_vpn_gateway" "cloud1" {
  region = var.regions[0]
  name = "${var.prefix}-havpn-cloud1"
  network = google_compute_network.left.id
}

resource "google_compute_ha_vpn_gateway" "cloud2" {
  region = var.regions[1]
  name = "${var.prefix}-havpn-cloud2"
  network = google_compute_network.left.id
}

resource "google_compute_router" "onprem1" {
  name          = "${var.prefix}-cr-onprem1"
  network       = google_compute_network.onprem.id
  region        = var.regions[0]
  bgp {
    asn = 64901
  }
}
resource "google_compute_router" "onprem2" {
  name          = "${var.prefix}-cr-onprem1"
  network       = google_compute_network.onprem.id
  region        = var.regions[1]
  bgp {
    asn = 64901
  }
}

####################
# region 0
####################

resource "google_compute_router_interface" "onprem1_nic0" {
  name = "onprem1-nic0"
  router = google_compute_router.onprem1.name
  region = google_compute_router.onprem1.region
  ip_range = "169.254.1.1/30"
  vpn_tunnel = google_compute_vpn_tunnel.dc_cl1_0.name
}
resource "google_compute_router_interface" "onprem1_nic1" {
  name = "onprem1-nic1"
  router = google_compute_router.onprem1.name
  region = google_compute_router.onprem1.region
  ip_range = "169.254.1.5/30"
  vpn_tunnel = google_compute_vpn_tunnel.dc_cl1_1.name
}

resource "google_compute_router_interface" "cloud1_nic0" {
  name = "cloud1-nic0"
  router = module.ncc_region[var.regions[0]].left_cr.name
  region = module.ncc_region[var.regions[0]].left_cr.region
  ip_range = "169.254.1.2/30"
  vpn_tunnel = google_compute_vpn_tunnel.cl_dc1_0.name
}
resource "google_compute_router_interface" "cloud1_nic1" {
  name = "cloud1-nic1"
  router = module.ncc_region[var.regions[0]].left_cr.name
  region = module.ncc_region[var.regions[0]].left_cr.region
  ip_range = "169.254.1.6/30"
  vpn_tunnel = google_compute_vpn_tunnel.cl_dc1_1.name
}

resource "google_compute_vpn_tunnel" "dc_cl1_0" {
  name = "${var.prefix}-tun1-tocloud-0"
  region = var.regions[0]
  vpn_gateway = google_compute_ha_vpn_gateway.onprem1.id
  peer_gcp_gateway = google_compute_ha_vpn_gateway.cloud1.id
  vpn_gateway_interface = 0
  router = google_compute_router.onprem1.id
  shared_secret = "supersecretpassword"
}
resource "google_compute_vpn_tunnel" "dc_cl1_1" {
  name = "${var.prefix}-tun1-tocloud-1"
  region = var.regions[0]
  vpn_gateway = google_compute_ha_vpn_gateway.onprem1.id
  peer_gcp_gateway = google_compute_ha_vpn_gateway.cloud1.id
  vpn_gateway_interface = 1
  router = google_compute_router.onprem1.id
  shared_secret = "supersecretpassword"
}

resource "google_compute_vpn_tunnel" "cl_dc1_0" {
  name = "${var.prefix}-tun1-toprem-0"
  region = var.regions[0]
  vpn_gateway = google_compute_ha_vpn_gateway.cloud1.id
  peer_gcp_gateway = google_compute_ha_vpn_gateway.onprem1.id
  vpn_gateway_interface = 0
  router = module.ncc_region[var.regions[0]].left_cr.id
  shared_secret = "supersecretpassword"
}
resource "google_compute_vpn_tunnel" "cl_dc1_1" {
  name = "${var.prefix}-tun1-toprem-1"
  region = var.regions[0]
  vpn_gateway = google_compute_ha_vpn_gateway.cloud1.id
  peer_gcp_gateway = google_compute_ha_vpn_gateway.onprem1.id
  vpn_gateway_interface = 1
  router = module.ncc_region[var.regions[0]].left_cr.id
  shared_secret = "supersecretpassword"
}


resource "google_compute_router_peer" "onprem1_cloud1" {
  name                      = "onprem1-cloud1"
  router                    = google_compute_router.onprem1.name
  region                    = var.regions[0]
  peer_ip_address           = split("/", google_compute_router_interface.cloud1_nic0.ip_range)[0]
  peer_asn                  = var.asns_left_ncc[0]
  advertised_route_priority = 100
  interface                 = google_compute_router_interface.onprem1_nic0.name
}
resource "google_compute_router_peer" "cloud1_onprem1" {
  name                      = "cloud1-onprem1"
  router                    = module.ncc_region[var.regions[0]].left_cr.name
  region                    = var.regions[0]
  peer_ip_address           = split("/", google_compute_router_interface.onprem1_nic0.ip_range)[0]
  peer_asn                  = google_compute_router.onprem1.bgp[0].asn
  advertised_route_priority = 100
  interface                 = google_compute_router_interface.cloud1_nic0.name
  advertise_mode            = "CUSTOM"
}

resource "google_compute_router_peer" "onprem1_cloud1b" {
  name                      = "onprem1-cloud1b"
  router                    = google_compute_router.onprem1.name
  region                    = var.regions[0]
  peer_ip_address           = split("/", google_compute_router_interface.cloud1_nic1.ip_range)[0]
  peer_asn                  = var.asns_left_ncc[0]
  advertised_route_priority = 100
  interface                 = google_compute_router_interface.onprem1_nic1.name
}
resource "google_compute_router_peer" "cloud1_onprem1b" {
  name                      = "cloud1-onprem1b"
  router                    = module.ncc_region[var.regions[0]].left_cr.name
  region                    = var.regions[0]
  peer_ip_address           = split("/", google_compute_router_interface.onprem1_nic1.ip_range)[0]
  peer_asn                  = google_compute_router.onprem1.bgp[0].asn
  advertised_route_priority = 100
  interface                 = google_compute_router_interface.cloud1_nic1.name
  advertise_mode            = "CUSTOM"
}

####################
# region 1
####################

resource "google_compute_router_interface" "onprem2_nic0" {
  name = "onprem1-nic0"
  router = google_compute_router.onprem2.name
  region = google_compute_router.onprem2.region
  ip_range = "169.254.2.1/30"
  vpn_tunnel = google_compute_vpn_tunnel.dc_cl2_0.name
}
resource "google_compute_router_interface" "onprem2_nic1" {
  name = "onprem1-nic1"
  router = google_compute_router.onprem2.name
  region = google_compute_router.onprem2.region
  ip_range = "169.254.2.5/30"
  vpn_tunnel = google_compute_vpn_tunnel.dc_cl2_1.name
}

resource "google_compute_router_interface" "cloud2_nic0" {
  name = "cloud2-nic0"
  router = module.ncc_region[var.regions[1]].left_cr.name
  region = module.ncc_region[var.regions[1]].left_cr.region
  ip_range = "169.254.2.2/30"
  vpn_tunnel = google_compute_vpn_tunnel.cl_dc2_0.name
}
resource "google_compute_router_interface" "cloud2_nic1" {
  name = "cloud2-nic1"
  router = module.ncc_region[var.regions[1]].left_cr.name
  region = module.ncc_region[var.regions[1]].left_cr.region
  ip_range = "169.254.2.6/30"
  vpn_tunnel = google_compute_vpn_tunnel.cl_dc2_1.name
}

resource "google_compute_vpn_tunnel" "dc_cl2_0" {
  name = "${var.prefix}-tun2-tocloud-0"
  region = var.regions[1]
  vpn_gateway = google_compute_ha_vpn_gateway.onprem2.id
  peer_gcp_gateway = google_compute_ha_vpn_gateway.cloud2.id
  vpn_gateway_interface = 0
  router = google_compute_router.onprem2.id
  shared_secret = "supersecretpassword"
}
resource "google_compute_vpn_tunnel" "dc_cl2_1" {
  name = "${var.prefix}-tun2-tocloud-1"
  region = var.regions[1]
  vpn_gateway = google_compute_ha_vpn_gateway.onprem2.id
  peer_gcp_gateway = google_compute_ha_vpn_gateway.cloud2.id
  vpn_gateway_interface = 1
  router = google_compute_router.onprem2.id
  shared_secret = "supersecretpassword"
}

resource "google_compute_vpn_tunnel" "cl_dc2_0" {
  name = "${var.prefix}-tun2-toprem-0"
  region = var.regions[1]
  vpn_gateway = google_compute_ha_vpn_gateway.cloud2.id
  peer_gcp_gateway = google_compute_ha_vpn_gateway.onprem2.id
  vpn_gateway_interface = 0
  router = module.ncc_region[var.regions[1]].left_cr.id
  shared_secret = "supersecretpassword"
}
resource "google_compute_vpn_tunnel" "cl_dc2_1" {
  name = "${var.prefix}-tun2-toprem-1"
  region = var.regions[1]
  vpn_gateway = google_compute_ha_vpn_gateway.cloud2.id
  peer_gcp_gateway = google_compute_ha_vpn_gateway.onprem2.id
  vpn_gateway_interface = 1
  router = module.ncc_region[var.regions[1]].left_cr.id
  shared_secret = "supersecretpassword"
}


resource "google_compute_router_peer" "onprem2_cloud2" {
  name                      = "onprem2-cloud2"
  router                    = google_compute_router.onprem2.name
  region                    = var.regions[1]
  peer_ip_address           = split("/", google_compute_router_interface.cloud2_nic0.ip_range)[0]
  peer_asn                  = var.asns_left_ncc[1]
  advertised_route_priority = 100
  interface                 = google_compute_router_interface.onprem2_nic0.name
}
resource "google_compute_router_peer" "cloud2_onprem2" {
  name                      = "cloud2-onprem2"
  router                    = module.ncc_region[var.regions[1]].left_cr.name
  region                    = var.regions[1]
  peer_ip_address           = split("/", google_compute_router_interface.onprem2_nic0.ip_range)[0]
  peer_asn                  = google_compute_router.onprem2.bgp[0].asn
  advertised_route_priority = 100
  interface                 = google_compute_router_interface.cloud2_nic0.name
  advertise_mode            = "CUSTOM"
}

resource "google_compute_router_peer" "onprem2_cloud2b" {
  name                      = "onprem2-cloud2b"
  router                    = google_compute_router.onprem2.name
  region                    = var.regions[1]
  peer_ip_address           = split("/", google_compute_router_interface.cloud2_nic1.ip_range)[0]
  peer_asn                  = var.asns_left_ncc[1]
  advertised_route_priority = 100
  interface                 = google_compute_router_interface.onprem2_nic1.name
}
resource "google_compute_router_peer" "cloud2_onprem2b" {
  name                      = "cloud2-onprem2b"
  router                    = module.ncc_region[var.regions[1]].left_cr.name
  region                    = var.regions[1]
  peer_ip_address           = split("/", google_compute_router_interface.onprem2_nic1.ip_range)[0]
  peer_asn                  = google_compute_router.onprem2.bgp[0].asn
  advertised_route_priority = 100
  interface                 = google_compute_router_interface.cloud2_nic1.name
  advertise_mode            = "CUSTOM"
}

###################################
# NCC

resource "google_network_connectivity_spoke" "tun1" {
  name          = "${var.prefix}-tun1"
  location      = var.regions[0]
  hub           = google_network_connectivity_hub.hub.id

  linked_vpn_tunnels {
    site_to_site_data_transfer = true
    uris = [
      google_compute_vpn_tunnel.cl_dc1_0.id,
      google_compute_vpn_tunnel.cl_dc1_1.id,
    ]
  }
}


resource "google_network_connectivity_spoke" "tun2" {
  name          = "${var.prefix}-tun2"
  location      = var.regions[1]
  hub           = google_network_connectivity_hub.hub.id

  linked_vpn_tunnels {
    site_to_site_data_transfer = true
    uris = [
      google_compute_vpn_tunnel.cl_dc2_0.id,
      google_compute_vpn_tunnel.cl_dc2_1.id,
    ]
  }
}
