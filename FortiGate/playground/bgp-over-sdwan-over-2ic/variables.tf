variable "region" {
    type = string
    default = "europe-west1"
}

variable "prefix" {
    default = "bm-2ic"
}

variable "cidrs" {
    default = {
        "intfw" = "172.17.1.0/24"
        "extfw" = "172.17.0.0/24"
        "hamgmt" = "172.17.2.0/24"
        "remote" = "10.0.200.0/24"
        "intsrv" = "10.0.100.0/24"
    }
    
}

locals {
  fwcloud = [
    "172.18.100.10",
    "172.18.100.11"
  ]
  //fwremote = [cidrhost(var.cidrs.remote, 11), cidrhost(var.cidrs.remote, 12)]
  fwremote = [
    "172.18.200.10",
    "172.18.200.11"
  ]
}

variable "overlay" {
  default = "10.254.1.0/24"
}

locals {
  overlay_gcp = cidrhost( var.overlay, 1 )
  overlay_remote = cidrhost( var.overlay, 2 )
}

variable "flex_tokens" {
  type = list(string)
  default = ["", "", ""]
}

variable "fgt_sa" {
  type = string
  default = ""
  description = "Service account to bind to FortiGate VMs. Defaults to default compute engine account"
}
