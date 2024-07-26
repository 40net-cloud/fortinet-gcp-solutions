output "mgmt_eip" {
  value = "https://${google_compute_address.pub["fwb1-port1"].address}:${var.admin_port}"
}

output "mgmt_password" {
  value = google_compute_instance.fwb[0].instance_id
}

output "frontend" {
  value = var.frontend_type == "nlb" ? google_compute_address.nlb[0].address : "http://${google_compute_global_address.alb[0].address}/"
}