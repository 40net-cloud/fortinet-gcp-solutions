variable "prefix" {
  description = "Prefix to be added to all resources"
  type        = string
  default     = "fgtncc-demo"
}

variable "regions" {
  type        = list(string)
  description = "List of 2 regions to deploy to."
  default = [
    "us-west4",
    "us-east1"
  ]
}

variable "netname_left" {
  description = "Name of left network (external)"
  default     = "ext"
  type        = string
}
variable "netname_right" {
  description = "Name of right network (internal)"
  default     = "int"
  type        = string
}
variable "netname_fgsp" {
  description = "Name of FGSP network"
  default     = "fgsp"
  type        = string
}

variable "asns_left_ncc" {}
variable "asns_right_ncc" {}
variable "asns_fgt" {}

variable "wrkld_cidrs" {
  type = map(list(string))
}

variable "flex_serials" {
  type    = list(string)
  default = []
}
variable "flex_config_id" {
  type    = number
  default = 0
}
