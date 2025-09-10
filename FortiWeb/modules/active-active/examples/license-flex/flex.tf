resource "fortiflexvm_entitlements_vm_token" "fwb" {
  count            = length(var.flex_serials)
  serial_number    = var.flex_serials[count.index]
  config_id        = var.flex_config_id
  regenerate_token = true
}

