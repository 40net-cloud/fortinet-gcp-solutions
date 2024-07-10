output "alb_address" {
    value = google_compute_global_address.alb.address
}

output "fgt_management_address" {
    value = module.fgt.fgt_mgmt_eips.port3-0.address
}

output "fgt_password" {
    value = module.fgt.fgt_password
}