resource "google_compute_route" "private_vpc_route" {
  name        = "${var.name}-internal-route-${var.random_string}"
  dest_range  = var.dest_range
  network     = var.private_vpc_network
  next_hop_ip = var.next_hop_ip
  priority    = var.priority
  depends_on  = [var.route_depends_on]
}
