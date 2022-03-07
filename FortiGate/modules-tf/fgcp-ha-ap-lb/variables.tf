terraform {
  required_providers {
    fortios = {
      source = "fortinetdev/fortios"
    }
  }
}

variable region {
  type = string
  default = "europe-west1"
  description = "Region to deploy all resources in. Must match var.zones if defined."
}

variable prefix {
  type = string
  description = "This prefix will be added to all created resources"
  default = "fgt"
}

variable zones {
  type = list(string)
  default = ["",""]
  description = "Names of zones to deploy FortiGate instances to matching the region variable. Defaults to first 2 zones in given region."
}

variable subnets {
  type = list(string)
  description = "Names of four existing subnets to be connected to FortiGate VMs (external, internal, heartbeat, management)"
  validation {
    condition = length(var.subnets) == 4
    error_message = "Please provide exactly 4 subnet names (external, internal, heartbeat, management)."
  }
}

variable machine_type {
  type = string
  description = "GCE machine type to use for VMs."
  default = "e2-standard-4"
}

variable service_account {
  type = string
  default = ""
  description = "E-mail of service account to be assigned to FortiGate VMs. Defaults to Default Compute Engine Account"
}

variable network_ip_offset {
  type = number
  default = 2
  description = "Offset for all static private IPs (e.g. 10.0.0.0/8 subnet and offset=2 will assign 10.0.0.2 to ILB, 10.0.0.3 and 10.0.0.4 to FortiGates)"
  validation {
    condition = var.network_ip_offset >= 2
    error_message = "Network IP offset cannot be smaller than 2."
  }
}

variable admin_acl {
  type = list(string)
  default = ["0.0.0.0/0"]
  description = "List of CIDRs allowed to connect to FortiGate management interfaces"
}

variable license_files {
  type = list(string)
  default = ["",""]
}

variable healthcheck_port {
  type = number
  default = 8008
}
