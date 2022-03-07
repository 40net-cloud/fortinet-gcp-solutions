# Auto-discover custom service account
data google_service_account fgt {
  account_id      = "fortigatesdn-ro"
}

# Create base deployment of FortiGate HA cluster
module "fortigates" {
  source          = "../../../../modules-tf/fgcp-ha-ap-lb"

  region          = var.GCE_REGION
  service_account = data.google_service_account.fgt.email != null ? data.google_service_account.fgt.email : ""

  # Use the below subnet names if you create new networks using sample_networks or update to your own
  # Remember to use subnet list as names. No selfLinks, please
   subnets        = [
     "${var.prefix}sb-external",
     "${var.prefix}sb-internal",
     "${var.prefix}sb-hasync",
     "${var.prefix}sb-mgmt"
   ]

  license_files   = [
    "../../../../lic1.lic",
    "../../../../lic2.lic"
  ]
}

## Uncomment below to create new networks
/*
module "sample_networks" {
  source          = "../modules/utils/sample-networks"

  prefix          = var.prefix
  region          = var.GCE_REGION
  networks        = ["external", "internal", "hasync", "mgmt"]
}

# If creating sample VPC Networks in the same configuration - wait for them to be created!
  depends_on    = [
    module.sample_networks
  ]
*/
