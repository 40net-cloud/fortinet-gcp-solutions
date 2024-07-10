resource "google_compute_network" "vpcs" {
  for_each = toset(var.net_names)
  name     = "${var.prefix}-${each.value}"
}

locals {
  cidr = {
    "ext" : "172.20.1.0/24",
    "int" : "172.20.2.0/24",
    "hasync" : "172.20.3.0/24"
  }

}

resource "google_compute_subnetwork" "nets" {
  for_each      = toset(var.net_names)
  name          = "${var.prefix}-${each.value}-euw6"
  network       = google_compute_network.vpcs[each.value].id
  ip_cidr_range = local.cidr[each.value]
  region        = var.region
}

module "fgt" {
  source = "git::github.com/fortinet/terraform-google-fgt-ha-ap-lb?ref=v1.1"

  prefix    = var.prefix
  region    = var.region
  subnets   = [for base in var.net_names : google_compute_subnetwork.nets[base].name]
  frontends = ["nlb1"]
  fgt_config = templatefile("fortigate_config.tftpl", {backend_address = google_compute_address.srv.address})

  flex_tokens = var.flex
  image = {
    version = "7.4"
  }

  depends_on = [google_compute_subnetwork.nets]
}
