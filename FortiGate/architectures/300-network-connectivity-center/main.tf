terraform {
  required_providers {
    fortiflexvm = {
      source = "fortinetdev/fortiflexvm"
    }
  }
}

resource "google_network_connectivity_hub" "hub" {
  name = "${var.prefix}-hub"
}


module "ncc_region" {
  source   = "./ncc-region"
  for_each = toset(var.regions)

  region    = each.key
  prefix    = var.prefix
  hub       = google_network_connectivity_hub.hub
  indx      = index(var.regions, each.key)
  net_left  = google_compute_network.left
  net_right = google_compute_network.right
  net_fgsp  = google_compute_network.fgsp

  asn_left_ncc  = var.asns_left_ncc[index(var.regions, each.key)]
  asn_right_ncc = var.asns_right_ncc[index(var.regions, each.key)]
  asn_fgt       = var.asns_fgt[index(var.regions, each.key)]

  //  custom_ip_ranges = var.wrkld_cidrs[each.key] #single region annoncements
  custom_ip_ranges = flatten(values(var.wrkld_cidrs))

  flex_tokens = [for serial in slice(var.flex_serials, index(var.regions, each.key) * 2, (index(var.regions, each.key) + 1) * 2) : fortiflexvm_entitlements_vm_token.fgts[serial].token]
}

output "frontend_eips" {
  value = [for ncc in module.ncc_region : ncc.frontend_eip]
}
