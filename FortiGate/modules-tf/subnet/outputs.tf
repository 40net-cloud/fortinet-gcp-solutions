# Public Subnet
# output "public_subnet" {
#   value = google_compute_subnetwork.subnet[0].name
# }

# # Private Subnet
# output "private_subnet" {
#   value = google_compute_subnetwork.subnet[1].name
# }

# # Sync Subnet
# output "sync_subnet" {
#   value = google_compute_subnetwork.subnet[2].name
# }

# # Management Subnet
# output "mgmt_subnet" {
#   value = google_compute_subnetwork.subnet[3].name
# }

# Public Subnet Gateway Address
output "public_subnet_gateway_address" {
  value = google_compute_subnetwork.subnet[0].gateway_address
}

# All Subnets
output "subnets" {
  value       = google_compute_subnetwork.subnet[*].name
  description = "All Subnets"
}
