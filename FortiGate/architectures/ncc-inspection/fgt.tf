
module "fgt_image" {
  source = "git::https://github.com/fortinet/terraform-google-fgt-ha-ap-lb.git//modules/fgt-get-image?depth=1"
  ver    = "7.6.4"
  lic    = "byol"
}


module "fgt" {
  source       = "./modules/fgt-single"
  zone         = "${var.region}-b"
  subnet_mgmt  = module.net_mgmt.subnets["${var.region}/${local.prefix}sb-mgmt"]
  subnet_ra    = module.net_center.subnets["${var.region}/${local.prefix}sb-raspoke"]
  address_ra   = google_compute_address.fgt_ra.address
  boot_image   = module.fgt_image.self_link
  logdisk_size = 0
  labels       = var.labels
  fgt_asn      = var.fgt_asn
  ncc_asn      = var.ncc_asn
  bgp_peers    = google_compute_address.cr_ra_nics[*].address
}
