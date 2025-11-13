variable "fgt_tags" {
  type    = list(string)
  default = ["fgt"]
}

variable "region" {
  type        = string
  description = "Region to use for deployment"
  default     = "us-central1"
}

variable "prefix" {
  type        = string
  description = "(optional) Prefix added to names of all created resources"
  default     = "fgt"
}

variable "labels" {
  type        = map(string)
  description = "(optional) Labels to be added to resources"
  default     = {}
}

variable "spokes" {
  type = map(object({
    ip_cidr_range = string
    region = optional(string)
  }))
  default = {
    spoke1 = {
      ip_cidr_range = "10.10.201.0/24"
    },
    spoke2 = {
      ip_cidr_range = "10.10.202.0/24"
    }
  }
}

variable "fgt_asn" {
  type    = number
  default = 64512
}

variable "ncc_asn" {
  type    = number
  default = 64513
}
