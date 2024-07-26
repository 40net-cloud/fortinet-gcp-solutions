terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}

locals {
  ver = length(split(".", var.ver)) == 3 ? replace(var.ver, ".", "") : "${replace(var.ver, ".", "")}\\d{1,2}"
}


data "google_compute_image" "all" {
  project = "fortigcp-project-001"
  # if version is set search by version else null filter
  filter      = var.ver != "" ? "name eq fwb-${local.ver}-${var.lic}-\\d{8}-\\d{3}-w-license" : "name eq fwb-\\d{3,4}-payg-\\d{8}-\\d{3}-w-license"
  most_recent = "true"
}


output "image" {
  value = data.google_compute_image.all
}

output "self_link" {
  value = data.google_compute_image.all.self_link
}