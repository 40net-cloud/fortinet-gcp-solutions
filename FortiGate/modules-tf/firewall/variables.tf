# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# Generally, these values won't need to be changed.
# ---------------------------------------------------------------------------------------------------------------------
variable "random_string" {
  type        = string
  default     = "abc"
  description = "Random String"
}

variable "vpcs" {
  type        = list(string)
  description = "VPC Networks"
}

variable "source_ranges" {
  type        = list
  default     = ["0.0.0.0/0"]
  description = "Source Range"
}

variable "destination_ranges" {
  type        = list
  default     = ["0.0.0.0/0"]
  description = "Destination Range"
}

variable "allow_all" {
  type        = string
  default     = "all"
  description = "Default Allow Protocol"
}