

data "google_compute_default_service_account" "default" {}

locals {
    fgt_sa = coalesce( var.fgt_sa, data.google_compute_default_service_account.default.email)
}