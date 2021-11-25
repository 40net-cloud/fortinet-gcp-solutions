# HA-Cluster-IP
output "fgt_ha_cluster_ip" {
  value = "${google_compute_instance.active_instance.network_interface.0.access_config.0.nat_ip}"
}

# FortiGate-HA-Active-MGMT-IP
output "fgt_ha_active_mgmt_ip" {
  value = "${google_compute_instance.active_instance.network_interface.3.access_config.0.nat_ip}"
}

# Active-FortiGate-Username
output "active_fgt_username" {
  value = "admin"
}

# Active-FortiGate-Password
output "active_fgt_password" {
  value = var.password
}

# FortiGate-HA-Passive-MGMT-IP
output "fgt_ha_passive_mgmt_ip" {
  value = "${google_compute_instance.passive_instance.network_interface.3.access_config.0.nat_ip}"
}

# Passive-FortiGate-Username
output "passive_fgt_username" {
  value = "admin"
}

# Passive-FortiGate-Password
output "passive_fgt_password" {
  value = var.password
}
