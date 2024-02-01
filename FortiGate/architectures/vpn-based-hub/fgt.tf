module "fgt_ha" {
  #lock to specific commit
  source = "git::github.com/fortinet/terraform-google-fgt-ha-ap-lb?ref=88fb453df3f529dd808f9a245487e17c75c41e32"

  region        = var.region
  subnets       = [module.networks["ext"].subnets_names[0], module.networks["hub"].subnets_names[0], module.networks["hasync"].subnets_names[0], module.networks["mgmt"].subnets_names[0]]
  labels        = var.labels
  prefix        = var.prefix
  routes = {}
  image_family  = "fortigate-74-byol"
  flexvm_tokens = [for vm in fortiflexvm_entitlements_vm_token.fgt : vm.token]
  fgt_config = <<EOT
  config router static
    edit 0
    set dst 10.10.0.0/16
    set device port2
    set gateway ${cidrhost(module.networks["hub"].subnets_ips[0], 1)}
    next
  end
  config firewall address
      edit "spoke1"
        set type dynamic
        set sdn "gcp"
        set associated-interface "port2"
        set filter "Network=${var.prefix}-vpc-spoke1"
    next
    edit "spoke2"
        set type dynamic
        set sdn "gcp"
        set associated-interface "port2"
        set filter "Network=${var.prefix}-vpc-spoke2"
    next
  end
  config fire poli
    edit 0
    set name "spoke1-spoke2"
    set srcintf port2
    set dstintf port2
    set action accept
    set srcaddr "spoke1"
    set dstaddr "spoke2"
    set schedule "always"
    set service "ALL"
    set utm-status enable
    set ssl-ssh-profile "custom-deep-inspection"
    set av-profile "default"
    set nat disable
    set logtraffic all
    next
  end
  EOT
  depends_on = [module.networks]
}

######################
#   Flex licensing   #
######################


# Tell Terraform you will be using fortiflexvm provider published by fortinetdev
terraform {
  required_providers {
    fortiflexvm = {
      version = "2.2.0"
      source  = "fortinetdev/fortiflexvm"
    }
  }
}

# Configure the FortiFlex provider by providing username and password for the API
# Credentials can be provided using variables, environment or pulled from secure storage (as here)
# NEVER STORE CREDENTIALS OR OTHER SENSITIVE INFORMATION IN YOUR CODE!

# Get Flex credentials from secure secret vault
data "google_secret_manager_secret_version" "flex_user" {
  secret = var.flex_username_secret_name
}
data "google_secret_manager_secret_version" "flex_pass" {
  secret = var.flex_passwd_secret_name
}

# Configure FortiFlex provider
provider "fortiflexvm" {
  username = data.google_secret_manager_secret_version.flex_user.secret_data
  password = data.google_secret_manager_secret_version.flex_pass.secret_data
}

# Find the proper config ID (many steps required):

## get program serial number...
data "fortiflexvm_programs_list" "all" {}

## get all configs for the first program in the list
data "fortiflexvm_configs_list" "program0" {
  program_serial_number = data.fortiflexvm_programs_list.all.programs[0].serial_number
}

## get all serials for all FortiGate configs
data "fortiflexvm_entitlements_list" "program0" {
  for_each  = toset([for config in data.fortiflexvm_configs_list.program0.configs : format("%d", config.id) if contains(["FGT_VM_Bundle", "FGT_VM_LCS"], config.product_type)])
  config_id = each.value
}

## save map of serial=>config_id to locals
locals {
  serials_to_config = { for vm in flatten([for id, config in data.fortiflexvm_entitlements_list.program0 : config.entitlements]) : vm.serial_number => vm.config_id }
}

# Get the FortiFlex token (set regenerate_token to true to make sure the token is not used)
# NOTE: leaving regenerate_token to true will regenerate token (even if not used) and change VM metadata on each terraform run
resource "fortiflexvm_entitlements_vm_token" "fgt" {
  for_each = toset(var.flex_serials)

  config_id        = local.serials_to_config[each.value]
  serial_number    = each.value
  regenerate_token = true # If set as false, the provider will only provide the token and not regenerate it.

  lifecycle {
    ignore_changes = [regenerate_token]
  }
}