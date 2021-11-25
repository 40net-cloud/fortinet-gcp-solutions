# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These parameters must be supplied when consuming this module.
# ---------------------------------------------------------------------------------------------------------------------
variable "region" {
  type        = string
  description = "Region"
}

variable "vpcs" {
  type        = list(string)
  description = "VPC Networks"
}

variable "subnets" {
  type        = list(string)
  description = "Create(s) Subnets with the labels"
  # default     = ["public-subnet", "private-subnet", "sync-subnet", "mgmt-subnet"]
}

variable "subnet_cidrs" {
  type        = list(string)
  description = "Subnets CIDR"
  # default   = ["172.18.0.0/24", "172.18.1.0/24", "172.18.2.0/24", "172.18.3.0/24"]
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

variable "public_vpc_network" {
  type        = string
  default     = "public_network_1"
  description = "Public VPC Network"
}

variable "private_vpc_network" {
  type        = string
  default     = "private_vpc_network_1"
  description = "Private VPC Network"
}

variable "sync_vpc_network" {
  type        = string
  default     = "sync_vpc_network_1"
  description = "Sync VPC Network"
}

variable "mgmt_vpc_network" {
  type        = string
  default     = "mgmt_vpc_network_1"
  description = "Management VPC Network"
}
