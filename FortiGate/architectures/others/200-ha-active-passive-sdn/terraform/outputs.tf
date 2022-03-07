# Output
output "FortiGate-HA-Cluster-IP" {
  value = module.instances.fgt_ha_cluster_ip
}

output "FortiGate-HA-Active-MGMT-IP" {
  value = module.instances.fgt_ha_active_mgmt_ip
}

output "Active-FortiGate-Username" {
  value = module.instances.active_fgt_username
}

output "Active-FortiGate-Password" {
  value = module.instances.active_fgt_password
}

output "FortiGate-HA-Passive-MGMT-IP" {
  value = module.instances.fgt_ha_passive_mgmt_ip
}

output "Passive-FortiGate-Username" {
  value = module.instances.passive_fgt_username
}

output "Passive-FortiGate-Password" {
  value = module.instances.passive_fgt_password
}
