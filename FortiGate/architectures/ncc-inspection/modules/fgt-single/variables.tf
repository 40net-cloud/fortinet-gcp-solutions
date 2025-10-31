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

variable "fgt_tags" {
  type        = list(string)
  default     = ["fgt"]
  description = "(optional) List of network tags assigned to FortiGate instance and to be open to all traffic."
}

variable "machine_type" {
  type        = string
  description = "GCE machine type to use for FortiGate NVA"
  default     = "e2-standard-4"
}

variable "logdisk_size" {
  type        = number
  description = "Size of optional logdisk to attach to FortiGate. Set to 0 for no logdisk"
  default     = 30
}

variable "boot_image" {
  type        = string
  description = "URL of base FortiGate image. Make sure it matches your licensing!"
}

variable "zone" {
  type        = string
  description = "Compute zone to use for deployment"
}

variable "service_account" {
  type        = string
  default     = ""
  description = "E-mail of service account to be assigned to FortiGate VM instance. Defaults to Default Compute Engine Account"
}

variable "serial_port_enable" {
  type        = bool
  default     = false
  description = "Set to true to enable access to VM serial console"
}

variable "oslogin_enable" {
  type        = bool
  default     = null
  nullable    = true
  description = "Used to enable or disalbe OS Login on the instance level."
}

variable "lic_flex_token" {
  type        = string
  description = "FortiFlex token to use for licensing"
  default     = null
}

variable "lic_licfile_contents" {
  type        = string
  description = "BYOL license file contents"
  default     = null
}

variable "subnet_mgmt" {
  type = object({
    id              = string
    name            = string
    gateway_address = string
  })
}

variable "subnet_ra" {
  type = object({
    id              = string
    name            = string
    gateway_address = string
    network         = string
    ip_cidr_range   = string
  })
}

variable "address_ra" {
  type     = string
  default  = null
  nullable = true
}
variable "address_mgmt_priv" {
  type     = string
  default  = null
  nullable = true
}
variable "address_mgmt_pub" {
  type     = string
  default  = null
  nullable = true
}

variable "fgt_asn" {
  type = string
}

variable "ncc_asn" {
  type = string
}

variable "bgp_peers" {
  type = list(string)
}
