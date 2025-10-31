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
    subnet_ip     = "10.0.0.0/24"
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
