## https://cloud.google.com/architecture/deploy-hub-spoke-vpc-network-topology#vpn

resource "google_compute_router" "hub" {
  name    = "${var.prefix}-rtr-hub"
  region  = var.region
  network = module.networks["hub"].network_id
  bgp {
    asn            = 65500
    advertise_mode = "CUSTOM"
    advertised_ip_ranges {
      range = var.nets["spoke1"]
    }
    advertised_ip_ranges {
      range = var.nets["spoke2"]
    }
  }
}

resource "google_compute_ha_vpn_gateway" "hub" {
  region  = var.region
  name    = "${var.prefix}-gw-hub"
  network = module.networks["hub"].network_id
}

resource "google_compute_router" "spoke1" {
  name    = "${var.prefix}-rtr-spoke1"
  region  = var.region
  network = module.networks["spoke1"].network_id
  bgp {
    asn = 65501
  }
}

resource "google_compute_ha_vpn_gateway" "spoke1" {
  region  = var.region
  name    = "${var.prefix}-gw-spoke1"
  network = module.networks["spoke1"].network_id
}


resource "google_compute_router" "spoke2" {
  name    = "${var.prefix}-rtr-spoke2"
  region  = var.region
  network = module.networks["spoke2"].network_id
  bgp {
    asn = 65502
  }
}

resource "google_compute_ha_vpn_gateway" "spoke2" {
  region  = var.region
  name    = "${var.prefix}-gw-spoke2"
  network = module.networks["spoke2"].network_id
}

module "vpn_spoke1" {
  source = "./vpcvpcvpn"

  prefix = var.prefix
  secret = "aoiuelsfdhbkITVG"
  left = {
    name   = "hub"
    gw     = google_compute_ha_vpn_gateway.hub
    router = google_compute_router.hub
  }
  right = {
    name   = "spoke1"
    gw     = google_compute_ha_vpn_gateway.spoke1
    router = google_compute_router.spoke1
  }

  tunnel_cidrs = [
    "169.254.1.0/30",
    "169.254.1.16/30"
  ]
}

module "vpn_spoke2" {
  source = "./vpcvpcvpn"

  prefix = var.prefix
  secret = "aoiuelsfdhbkITVG"
  left = {
    name   = "hub"
    gw     = google_compute_ha_vpn_gateway.hub
    router = google_compute_router.hub
  }
  right = {
    name   = "spoke2"
    gw     = google_compute_ha_vpn_gateway.spoke2
    router = google_compute_router.spoke2
  }

  tunnel_cidrs = [
    "169.254.2.0/30",
    "169.254.2.16/30"
  ]
}