# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These parameters must be supplied when consuming this module.
# ---------------------------------------------------------------------------------------------------------------------
variable "next_hop_ip" {
  type        = string
  description = "Next Hop IP"
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# Generally, these values won't need to be changed.
# ---------------------------------------------------------------------------------------------------------------------
variable "name" {
  type        = string
  default     = "terraform"
  description = "Name"
}

variable "random_string" {
  type        = string
  default     = "abc"
  description = "Random String"
}

variable "private_vpc_network" {
  type        = string
  default     = "private_vpc_network_1"
  description = "Private VPC Network"
}

variable "dest_range" {
  type        = string
  default     = "0.0.0.0/0"
  description = "Destination Range"
}

variable "priority" {
  type        = string
  default     = 100
  description = "Priority"
}

variable "route_depends_on" {
  type    = any
  default = null
}
