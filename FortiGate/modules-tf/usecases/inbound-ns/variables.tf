variable srv_name {
  type = string
  description = "Name of the service to be created. It will be used as part of resource names."
}

variable targets {
  type = list(object({
    ip = string
    port = number
    }))
  description = "List of target IP and port pairs for creating DNATs on FortiGate."
}

variable day0 {
  description = "Object containing all necessary data from day0 remote state. Common for all usecase modules."
}
