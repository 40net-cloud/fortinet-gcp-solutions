variable "spokes" {
  type = map(object({
    region = string
    ip_cidr_range = string
  }))
  default = {
    spoke1 = {
      region        = "us-central1"
      ip_cidr_range = "10.200.1.0/24"
    }
    spoke2 = {
      region        = "europe-west8"
      ip_cidr_range = "10.200.2.0/24"
    }
  }
  description = "Simple example map to define spoke VPCs and subnets properties"
}

variable "fgt_region" {
    type = string
    default = "europe-west8"
    description = "FortiGates will be deployed in this region"
}

variable "prefix" {
  type    = string
  default = "fgt-demo"
  description = "Prefix to be prepended to all resource names"
}

variable "fgt_subnet_cidrs" {
    type = map(string)
    default = {
        ext = "172.16.0.0/28"
        int = "172.16.0.16/28"
        hamgmt = "172.16.0.32/28"
    }
    description = "Map of CIDRs used for FortiGate directly connected subnets"
}

variable "fgt_admin_acl" {
    type = list(string)
    default = ["0.0.0.0/0"]
    description = "ACL for admin access to FortiGates. Do not use \"0.0.0.0/0\" in production deployments"
}