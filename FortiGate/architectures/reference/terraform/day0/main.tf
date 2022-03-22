# Auto-discover custom service account
# Use service_account_create.sh to create recommended minimal privileges service
# account. If not found the default Compute Engine account will be used.
data google_service_account fgt {
  account_id      = "fortigatesdn-ro"
}

data "http" "my_ip" {
  url             = "http://api.ipify.org"
}

# Create base deployment of FortiGate HA cluster
module "fortigates" {
  source          = "../../../../modules-tf/fgcp-ha-ap-lb"

  region          = var.GCE_REGION
  service_account = data.google_service_account.fgt.email != null ? data.google_service_account.fgt.email : ""
  api_acl         = ["${data.http.my_ip.body}/32"]

  # Use the below subnet names if you create new networks using sample_networks or update to your own
  # Remember to use subnet list as names, not selfLinks
  subnets         = [
     "${var.prefix}sb-external",
     "${var.prefix}sb-internal",
     "${var.prefix}sb-hasync",
     "${var.prefix}sb-mgmt"
   ]

  license_files   = [
    "lic1.lic",
    "lic2.lic"
  ]

  # If creating sample VPC Networks in the same configuration - wait for them to be created!
  depends_on    = [
    module.sample_networks
  ]
}

## Uncomment below to create new networks
module "sample_networks" {
  source          = "../../../../modules-tf/utils/sample-networks"

  prefix          = var.prefix
  region          = var.GCE_REGION
  networks        = ["external", "internal", "hasync", "mgmt"]
}
