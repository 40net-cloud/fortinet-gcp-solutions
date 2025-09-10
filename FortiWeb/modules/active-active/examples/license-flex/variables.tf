variable "prefix" {
  default = "demo-fwb"
}

variable "flex_config_id" {
  type     = number
  nullable = true
  default  = null
}

variable "flex_serials" {
  type     = list(string)
  nullable = true
  default  = null
}

variable "region" {
  type    = string
  default = "europe-west1"
}