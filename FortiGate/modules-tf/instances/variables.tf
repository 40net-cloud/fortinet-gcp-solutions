# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These parameters must be supplied when consuming this module.
# ---------------------------------------------------------------------------------------------------------------------
variable "service_account" {
  type        = string
  description = "Service Account"
}

variable "zone" {
  type        = string
  description = "Zone"
}

variable "machine" {
  type        = string
  description = "Machine Type"
}

variable "password" {
  type        = string
  default     = "ftntCl0ud"
  description = "FGT Password"
}

variable "image" {
  type        = string
  description = "FortiGate Image"
}

variable "license_file" {
  type        = string
  description = "License File"
}

variable "license_file_2" {
  type        = string
  description = "License File"
}

### User Data Variables ###
# Active Interface IP Assignments
# Active Public/External
variable "active_port1_ip" {
  type        = string
  description = "Active Instance Port1 IP Address"
}

variable "active_port1_mask" {
  type        = string
  description = "Active Instance Port1 Mask"
}

# Active Private/Internal
variable "active_port2_ip" {
  type        = string
  description = "Active Instance Port2 IP Address"
}

variable "active_port2_mask" {
  type        = string
  description = "Active Instance Port2 Mask"
}

# Active Sync
variable "active_port3_ip" {
  type        = string
  description = "Active Instance Port3 IP Address"
}

variable "active_port3_mask" {
  type        = string
  description = "Active Instance Port3 Mask"
}

# Active HA Managment
variable "active_port4_ip" {
  type        = string
  description = "Active Instance Port4 IP Address"
}

variable "active_port4_mask" {
  type        = string
  description = "Active Instance Port4 Mask"
}

# Passive Interface IP Assignments
# Passive Public/External
variable "passive_port1_ip" {
  type        = string
  description = "Passive Instance Port1 IP Address"
}

variable "passive_port1_mask" {
  type        = string
  description = "Passive Instance Port1 Mask"
}

# Passive Private/Internal
variable "passive_port2_ip" {
  type        = string
  description = "Passive Instance Port2 IP Address"
}

variable "passive_port2_mask" {
  type        = string
  description = "Passive Instance Port2 Mask"
}

# Passive Sync
variable "passive_port3_ip" {
  type        = string
  description = "Passive Instance Port3 IP Address"
}

variable "passive_port3_mask" {
  type        = string
  description = "Passive Instance Port3 Mask"
}

# Passive HA Management
variable "passive_port4_ip" {
  type        = string
  description = "Passive Instance Port4 IP Address"
}

variable "passive_port4_mask" {
  type        = string
  description = "Passive Instance Port4 Mask"
}

# HA Management Gateway IP, depends on the Management Subnet CIDR
variable "mgmt_gateway" {
  type        = string
  description = "Managment Gateway"
}

variable "mgmt_mask" {
  type        = string
  description = "Managment Mask"
}

variable "public_subnet_gateway" {
  type        = string
  description = "Active Instance Port1 Gateway"
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
  default     = "public_vpc_network_1"
  description = "Public VPC Network"
}

variable "private_vpc_network" {
  default     = "private_vpc_network_1"
  description = "Private VPC Network"
}

variable "sync_vpc_network" {
  default     = "sync_vpc_network_1"
  description = "Sync VPC Network"
}

variable "mgmt_vpc_network" {
  default     = "mgmt_vpc_network_1"
  description = "Management VPC Network"
}

variable "public_subnet" {
  default     = "public_subnet"
  description = "Public Subnet"
}

variable "private_subnet" {
  default     = "private_subnet"
  description = "Private Subnet"
}

variable "sync_subnet" {
  default     = "sync_subnet"
  description = "Sync Subnet"
}

variable "mgmt_subnet" {
  default     = "mgmt_subnet"
  description = "Management Subnet"
}

variable "static_ip" {
  default     = "static_ip"
  description = "Static IP Address"
}
