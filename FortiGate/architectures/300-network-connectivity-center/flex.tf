/*
terraform {
  required_providers {
    fortiflexvm = {
      source  = "fortinetdev/fortiflexvm"
    }
  }
}
*/


/*
data "google_secret_manager_secret_version" "flex_user" {
  secret = var.flex
}

data "google_secret_manager_secret_version" "flex_pwd" {
  secret = "bm-flex-pwd"
}

provider "fortiflexvm" {
  username = data.google_secret_manager_secret_version.flex_user.secret_data
  password = data.google_secret_manager_secret_version.flex_pwd.secret_data
}
*/

resource "fortiflexvm_entitlements_vm" "fgts" {
  for_each      = toset(var.flex_serials)
  config_id     = var.flex_config_id
  serial_number = each.key
  status        = "ACTIVE"
}

resource "fortiflexvm_entitlements_vm_token" "fgts" {
  for_each = toset(var.flex_serials)

  config_id        = var.flex_config_id
  serial_number    = each.key
  regenerate_token = true # If set as false, the provider would only provide the token and not regenerate the token.
  lifecycle {
    //ignore_changes = [status]
  }
  depends_on = [fortiflexvm_entitlements_vm.fgts]
}

