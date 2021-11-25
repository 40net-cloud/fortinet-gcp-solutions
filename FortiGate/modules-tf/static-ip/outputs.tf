# Static IP
output "static_ip" {
  value = "${google_compute_address.static.address}"
}
