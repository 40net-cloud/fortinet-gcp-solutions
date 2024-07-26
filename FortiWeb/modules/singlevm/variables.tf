variable "prefix" {
  type        = string
  default     = "fwb"
  description = "This prefix will be added to all created resources"
}

variable "zone" {
  type        = string
  default     = ""
  description = "Names of zones to deploy FortiGate instances to matching the region variable. Defaults to first 2 zones in given region."
}

variable "subnets" {
  type        = list(string)
  description = "Names of four existing subnets to be connected to FortiGate VMs (external, internal, heartbeat, management)"
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

variable "admin_acl" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "List of CIDRs allowed to connect to FortiGate management interfaces"
}

variable "admin_port" {
  type = number
  default = 8443
  description = "Port for administrative interface"
}

variable "api_acl" {
  type        = list(string)
  default     = []
  description = "List of CIDRs allowed to connect to FortiGate API (must not be 0.0.0.0/0)"
}

variable "image" {
  type = object({
    project = optional(string, "fortigcp-project-001")
    name    = optional(string, "")
    version = optional(string, "")
    license = optional(string, "payg")
  })
  description = "Indicate FortiWeb image you want to deploy by specifying either firmware version and licensing (as image.version, image.arch and image.lic), or explicit image name (as image.name) optionally with image project name for custom images (as image.project)."
  validation {
    condition     = contains(["payg", "byol"], var.image.license)
    error_message = "Value of image.license can be either 'payg' or 'byol' (default: 'payg'). For FortiFlex use 'byol'."
  }
  validation {
    condition     = anytrue([length(split(".", var.image.version)) == 3, length(split(".", var.image.version)) == 2, var.image.version == ""])
    error_message = "Value of image.version can be either empty or contain FortiWeb version in 3-digit format (eg. \"7.4.1\") or major version in 2-digit format (eg. \"7.4\")."
  }
}

variable "tags" {
  type    = list(string)
  default = ["fortiweb"]
}

variable "labels" {
  type        = map(string)
  description = "Map of labels to be applied to the VMs, disks, and forwarding rules"
  default     = {}
}

variable "flex_token" {
  type     = string
  nullable = true
  default  = null
}

variable "license" {
  type     = string
  nullable = true
  default  = ""
}

variable "config" {
  type        = string
  nullable    = true
  default     = null
  description = "Custom configuration to be added to FortiWeb instance."
}