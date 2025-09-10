
variable "cidr_left" {
  default = "172.20.0.0/24"
}
variable "cidr_right" {
  default = "172.20.1.0/24"
}
variable "cidr_fgsp" {
  default = "172.20.2.0/24"
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

variable "net_left" {}
variable "net_right" {}
variable "net_fgsp" {}

variable "prefix" {}
variable "indx" {}
variable "region" {}

variable "asn_left_ncc" {}
variable "asn_right_ncc" {}
variable "asn_fgt" {}

variable "cluster_size" {
  default = 2
}
variable "image_family" {
  type        = string
  description = "Image family. Overriden by providing explicit image name"
  default     = "fortigate-76-byol"
  validation {
    condition     = can(regex("^fortigate-[67][0-9]-(byol|payg)$", var.image_family))
    error_message = "The image_family is always in form 'fortigate-[major version]-[payg or byol]' (eg. 'fortigate-72-byol')."
  }
}

variable "image_name" {
  type        = string
  description = "Image name. Overrides var.firmware_family"
  default     = null
  nullable    = true
}

variable "image_project" {
  type        = string
  description = "Project hosting the image. Defaults to Fortinet public project"
  default     = "fortigcp-project-001"
}

variable "zones" {
  type        = list(string)
  default     = ["", ""]
  description = "Names of zones to deploy FortiGate instances to matching the region variable. Defaults to first 2 zones in given region."
}

variable "logdisk_size" {
  type        = number
  description = "Size of the attached logdisk in GB"
  default     = 30
  validation {
    condition     = var.logdisk_size > 10
    error_message = "Log disk size cannot be smaller than 10GB."
  }
}

variable "machine_type" {
  type        = string
  default     = "e2-standard-4"
  description = "GCE machine type to use for VMs. Minimum 4 vCPUs are needed for 4 NICs"
}

variable "service_account" {
  type        = string
  default     = ""
  description = "E-mail of service account to be assigned to FortiGate VMs. Defaults to Default Compute Engine Account"
}

variable "hub" {}

variable "custom_ip_ranges" {
  description = "List of CIDRs to additionally advertise from right cloud router"
}

variable "flex_tokens" {
  type = list(string)
}
