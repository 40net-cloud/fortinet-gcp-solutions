output "mgmt_eip" {
  value = google_compute_address.pub["port1"].address
}

output "mgmt_password" {
  value = google_compute_instance.fwb.instance_id
}