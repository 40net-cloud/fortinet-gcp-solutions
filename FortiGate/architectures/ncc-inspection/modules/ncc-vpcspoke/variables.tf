variable "prefix" {
  type        = string
  description = "(optional) Prefix added to names of all created resources"
  default     = ""
}

variable "labels" {
  type        = map(string)
  description = "(optional) Labels to be added to resources"
  default     = {}
}

variable "region" {
  type = string
}

variable "ip_cidr_range" {
  type = string
}

variable "ncc_hub_id" {
  type = string
}

variable "ncc_group_id" {
  type = string
}

variable "default_route_next_hop" {
  type = string
}
