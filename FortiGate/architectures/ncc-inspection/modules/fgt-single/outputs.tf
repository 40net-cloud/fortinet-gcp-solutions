output "self_link" {
  value = google_compute_instance.fgt_vm.self_link
}

output "ilb_ip" {
  value = google_compute_forwarding_rule.ilb.ip_address
}
