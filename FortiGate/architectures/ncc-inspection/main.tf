terraform {
  required_providers {
/*    fortiflexvm = {
      source = "fortinetdev/fortiflexvm"
    }
*/
  }
}

data "google_client_config" "default" {}

locals {
  spokes = {
    spoke1 = {
      ip_cidr_range = "10.10.201.0/24"
    },
    spoke2 = {
      ip_cidr_range = "10.10.202.0/24"
    }
  }
}

locals {
  # If prefix is defined, add a "-" spacer after it
  prefix = length(var.prefix) > 0 && substr(var.prefix, -1, 1) != "-" ? "${var.prefix}-" : var.prefix

  # get the project from default client config
  project_id = data.google_client_config.default.project
}



