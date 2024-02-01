variable "prefix" {
  type    = string
  default = "fgt-demo"
}

variable "labels" {
  type = map(string)
  default = {
    "owner" : "bmoczulski"
  }
}

variable "region" {
  type    = string
  default = "europe-west1"
}

variable "nets" {
  type = map(string)
  default = {
    "ext" : "172.20.0.0/24"
    "hub" : "10.0.0.0/24"
    "hasync" : "172.20.2.0/24"
    "mgmt" : "172.20.3.0/24"
    "spoke1" : "10.10.1.0/24"
    "spoke2" : "10.10.2.0/24"
  }
}

variable "flex_username_secret_name" {
  type        = string
  description = "Name of the secret in Secret Manager storing the FortiFlex API username"
}

variable "flex_passwd_secret_name" {
  type        = string
  description = "Name of the secret in Secret Manager storing the FortiFlex API password"
}

variable "flex_serials" {
  type    = list(string)
  default = []
}