module "networks" {
  source   = "terraform-google-modules/network/google"
  for_each = var.nets

  project_id                             = data.google_client_config.default.project
  network_name                           = "${var.prefix}-vpc-${each.key}"
  routing_mode                           = "GLOBAL"

  subnets = [
    {
      subnet_name   = "${var.prefix}-sb-${each.key}"
      subnet_ip     = each.value
      subnet_region = var.region
    }
  ]
  ingress_rules = [
    {
      name          = "${var.prefix}-fw-${each.key}-openall"
      source_ranges = ["0.0.0.0/0"]
      allow = [{
        protocol = "all"
      }]
    }
  ]
}