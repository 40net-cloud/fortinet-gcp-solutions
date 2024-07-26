variable "ver" {
  type        = string
  description = "FortiWeb firmware version, eg. \"7.4.1\"."
  default     = ""
  validation {
    condition     = var.ver == "" || contains([2, 3], try(length(split(".", var.ver)), 0))
    error_message = "Firmware version must be 2 or 3 numbers separated by dot (eg. 7.2 or 7.2.7), or empty string."
  }
}

variable "lic" {
  type        = string
  default     = "payg"
  description = "Licensing type. Allowed values are \"payg\" (default) and \"byol\"."
  validation {
    condition     = contains(["payg", "byol"], var.lic)
    error_message = "Licensing can be either 'payg' or 'byol' (default: 'payg'). For FortiFlex use 'byol'"
  }
}