resource "google_compute_network" "ext" {
    name = "${var.prefix}-ext"
    auto_create_subnetworks = false
    routing_mode = "GLOBAL"
}

resource "google_compute_network" "int" {
    name = "${var.prefix}-int"
    auto_create_subnetworks = false
    routing_mode = "GLOBAL"
}

resource "google_compute_network" "hamgmt" {
    name = "${var.prefix}-hamgmt"
    auto_create_subnetworks = false
    routing_mode = "GLOBAL"
}

resource "google_compute_network" "remote" {
    name = "${var.prefix}-remote"
    auto_create_subnetworks = false
    routing_mode = "GLOBAL"
}

/******* SUBNETS ***********/

resource "google_compute_subnetwork" "intfw" {
    name = "${var.prefix}-intfw"
    network = google_compute_network.int.id
    region = var.region
    ip_cidr_range = var.cidrs.intfw
}

resource "google_compute_subnetwork" "intsrv" {
    name = "${var.prefix}-intsrv"
    network = google_compute_network.int.id
    region = var.region
    ip_cidr_range = var.cidrs.intsrv
}

resource "google_compute_subnetwork" "extfw" {
    name = "${var.prefix}-extfw"
    network = google_compute_network.ext.id
    region = var.region
    ip_cidr_range = var.cidrs.extfw
}

resource "google_compute_subnetwork" "hamgmt" {
    name = "${var.prefix}-hamgmt"
    network = google_compute_network.hamgmt.id
    region = var.region
    ip_cidr_range = var.cidrs.hamgmt
}

resource "google_compute_subnetwork" "remote" {
    name = "${var.prefix}-remote"
    network = google_compute_network.remote.id
    region = var.region
    ip_cidr_range = var.cidrs.remote
    secondary_ip_range = [ 
        {
            range_name = "vpn"
            ip_cidr_range = "172.18.200.0/24"
        }
     ]
}

resource "google_compute_firewall" "r_allowadmin" {
    name = "${var.prefix}-r-allowadmin"
    network = google_compute_network.remote.id
    source_ranges = ["0.0.0.0/0"]
    allow {
      protocol = "TCP"
      ports = [ "443", "22" ]
    }
}

resource "google_compute_firewall" "r_underlay" {
    name = "${var.prefix}-r-underlay"
    network = google_compute_network.remote.id
    source_ranges = ["172.18.100.0/24"]
    destination_ranges = [ "172.18.200.0/24" ]
    allow {
      protocol = "all"
    }
}

resource "google_compute_firewall" "viavpn" {
    name = "${var.prefix}-r-viavpn"
    network = google_compute_network.remote.id
    source_ranges = ["10.0.200.0/24"]
    destination_ranges = [ "10.0.100.0/24" ]
    allow {
      protocol = "all"
    }    
}


resource "google_compute_route" "viavpn" {
    name = "${var.prefix}-remote-via-fgt"
    network = google_compute_network.int.id
    dest_range = var.cidrs["remote"]
    next_hop_ilb = module.fgtgcp.ilb_ids.port2
    tags = ["vpnclient"]
}

resource "google_compute_route" "gcpviavpn" {
    name = "${var.prefix}-gcp-via-fgt"
    network = google_compute_network.remote.id
    dest_range = var.cidrs["intsrv"]
    next_hop_ip = google_compute_instance.fgtremote.network_interface.0.network_ip
    tags = ["vpnclient"]
}