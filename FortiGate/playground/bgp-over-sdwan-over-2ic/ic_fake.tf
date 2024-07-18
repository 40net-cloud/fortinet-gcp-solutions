locals {
    regions = [var.region, "us-east1"] //module builds multi-regional HA, so lets follow it
}

resource "google_compute_router" "remote" {
  count = 2

  name   = "${var.prefix}-rtr-remote${count.index+1}"
  region = local.regions[count.index]
  network = google_compute_network.remote.id
  bgp {
    asn = 65510+count.index
    advertise_mode = "CUSTOM"
    advertised_groups = []
    advertised_ip_ranges {
      range = "${local.fwremote[count.index]}/32"
    }
  }
}

resource "google_compute_ha_vpn_gateway" "remote" {
  count = 2

  region   = local.regions[count.index]
  name     = "${var.prefix}-gw-remote${count.index+1}"
  network  = google_compute_network.remote.id
}

resource "google_compute_router" "gcp" {
  count = 2

  name   = "${var.prefix}-rtr-gcp${count.index+1}"
  region = local.regions[count.index]
  network = google_compute_network.ext.id
  bgp {
    asn = 65520+count.index
    advertise_mode = "CUSTOM"
    advertised_ip_ranges {
      range = "${local.fwcloud[count.index]}/32"
    }
  }
}

resource "google_compute_ha_vpn_gateway" "gcp" {
  count = 2

  region   = local.regions[count.index]
  name     = "${var.prefix}-gw-gcp${count.index+1}"
  network  = google_compute_network.ext.id
}

resource "random_string" "vpnpass" {
    length = 20
    special = true
}

module "vpn" {
    source = "./modules/vpcvpcvpn"
    count = 2

    prefix = var.prefix
    secret = random_string.vpnpass.result
    left = {
        name = "dc${count.index+1}"
        gw = google_compute_ha_vpn_gateway.remote[count.index]
        router = google_compute_router.remote[count.index]
    }
    right = {
        name = "ic${count.index+1}"
        gw = google_compute_ha_vpn_gateway.gcp[count.index]
        router = google_compute_router.gcp[count.index]
    }

    tunnel_cidrs = [
        "169.254.${count.index}.0/30",
        "169.254.${count.index}.16/30"
    ]
}