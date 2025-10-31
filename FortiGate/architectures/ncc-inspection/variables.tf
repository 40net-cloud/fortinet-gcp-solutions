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
  description = "(ooptional) Prefix added to names of all created resources"
  default     = "fgt"
}

variable "labels" {
  type        = map(string)
  description = "(optional) Labels to be added to resources"
  default     = {}
}

variable "fgt_asn" {
  type    = number
  default = 64512
}

variable "ncc_asn" {
  type    = number
  default = 64513
}
