# 
# Create missing external and ha/mgmt VPC networks for FortiGates
# 
module "net_ext" {
  source  = "terraform-google-modules/network/google"
  version = "12.0.0"

  project_id              = local.project_id
  network_name            = "${local.prefix}vpc-ext"
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"

  subnets = [{
    subnet_name   = "${local.prefix}sb-ext"
    subnet_region = var.region
    subnet_ip     = "10.0.0.0/26"
  }]

  ingress_rules = [{
    name          = "${local.prefix}fw-ext-allowmgmt"
    priority      = 200
    source_ranges = ["0.0.0.0/0"]
    target_tags   = var.fgt_tags
    allow = [{
      protocol = "all"
    }]
  }]
}

module "net_mgmt" {
  source  = "terraform-google-modules/network/google"
  version = "12.0.0"

  project_id              = local.project_id
  network_name            = "${local.prefix}vpc-mgmt"
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"

  subnets = [{
    subnet_name   = "${local.prefix}sb-mgmt"
    subnet_region = var.region
    subnet_ip     = "10.0.0.64/26"
  }]

  ingress_rules = [{
    name          = "${local.prefix}fw-mgmt-allowmgmt"
    priority      = 200
    source_ranges = ["0.0.0.0/0"]
    target_tags   = var.fgt_tags
    allow = [{
      protocol = "TCP"
      ports    = ["22", "443"]
    }]
  }]
}

#
# Deploy FortiGate cluster with port2 connected to the NCC "hub" VPC (central VPC spoke)
# 
# For more details on the module used here 
# see https://github.com/fortinet/terraform-google-fgt-ha-ap-lb
#
module "fgt_ha" {
  source        = "git::github.com/fortinet/terraform-google-fgt-ha-ap-lb"
#  source = "../../../../../fortinet/terraform-google-fgt-ha-ap-lb"
  zones         = [ "${var.region}-b", "${var.region}-c" ]
  prefix        = local.prefix
  labels = var.labels
  image = {
    license = "byol"
  }
  subnets       = [ 
    module.net_ext.subnets["${var.region}/${local.prefix}sb-ext"].name, 
    module.net_center.subnets["${var.region}/${local.prefix}sb-raspoke"].name, 
    module.net_mgmt.subnets["${var.region}/${local.prefix}sb-mgmt"].name 
    ]

  fgt_config = templatefile("${path.module}/fgt_config.tftpl", {
    fgt_asn = var.fgt_asn
    ncc_asn = var.ncc_asn
    bgp_peers = google_compute_address.cr_ra_nics[*].address
  })

  depends_on = [ 
    module.net_ext, 
    module.net_center, 
    module.net_mgmt
   ]
}

#
# For each edge spoke add a default route via FortiGate cluster
# 
resource "google_compute_route" "via_fgt" {
  for_each = var.spokes

  name         = "${var.prefix}${each.key}-default-via-fgt"
  network      = module.net_edges[each.key].network_id
  dest_range   = "0.0.0.0/0"
  next_hop_ilb = module.fgt_ha.ilb_addresses["port2"]
}


