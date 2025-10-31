terraform {
  required_providers {
    fortiflexvm = {
      source = "fortinetdev/fortiflexvm"
    }
  }
}

data "google_client_config" "default" {}

locals {
  # If prefix is defined, add a "-" spacer after it
  prefix = length(var.prefix) > 0 && substr(var.prefix, -1, 1) != "-" ? "${var.prefix}-" : var.prefix

  # get the project from default client config
  project_id = data.google_client_config.default.project
}


resource "google_compute_address" "fgt_ra" {
  name         = "${local.prefix}addr-fgt-ra"
  address_type = "INTERNAL"
  subnetwork   = module.net_center.subnets["${var.region}/${local.prefix}sb-raspoke"].id
  region       = var.region
}



