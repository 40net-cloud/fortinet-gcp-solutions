output "fgt1_mgmt" {
    value = module.fgt_ha.fgt_mgmt_eips[0]
}

output "fgt_passwd" {
    value = module.fgt_ha.fgt_password
}