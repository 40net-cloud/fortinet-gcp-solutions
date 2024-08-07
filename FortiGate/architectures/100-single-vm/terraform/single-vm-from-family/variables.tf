variable GCP_PROJECT {
  type    = string
  description = "GCP project id"
}

variable GCE_ZONE {
  type = string
  description = "GCE zone to use"
}

variable GCE_REGION {
  type = string
  description = "GCE region to use"
}

variable "prefix" {
  type = string
  description = "Prefix to be added to the names of all created resources"
}

provider "google" {
  project = var.GCP_PROJECT
  region  = var.GCE_REGION
  zone    = var.GCE_ZONE
}
