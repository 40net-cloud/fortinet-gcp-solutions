# Create external and management networks for FortiGates. Management will be also used for HA 
#
module "fgt_ext_network" {
  source  = "terraform-google-modules/network/google"
  version = "~> 10.0"

  project_id   = local.project_id
  network_name = "${var.prefix}-ext"

  subnets = [{
    subnet_name   = "${var.prefix}-ext-fgt"
    subnet_ip     = var.fgt_subnet_cidrs["ext"]
    subnet_region = var.fgt_region
    }
  ]

  ingress_rules = [
    {
      # Allow all inbound external traffic to FortiGate public interface
      name          = "${var.prefix}-ext-fgt-allowall"
      source_ranges = ["0.0.0.0/0"]
      target_tags   = ["fgt"]
      allow = [{
        protocol = "all"
      }]
    },
  ]
}

module "fgt_hamgmt_network" {
  source  = "terraform-google-modules/network/google"
  version = "~> 10.0"

  project_id   = local.project_id
  network_name = "${var.prefix}-admin"

  subnets = [{
    subnet_name   = "${var.prefix}-hamgmt-fgt"
    subnet_ip     = var.fgt_subnet_cidrs["hamgmt"]
    subnet_region = var.fgt_region
    }
  ]

  ingress_rules = [
    {
        name = "${var.prefix}-fgt-hasync"
        source_tags = ["fgt"]
        target_tags = ["fgt"]
        allow = [{
            protocol = "all"
        }]
    },
    {
      # Allow all inbound external traffic to FortiGate public interface
      name          = "${var.prefix}-fgt-admin"
      source_ranges = var.fgt_admin_acl
      target_tags   = ["fgt"]
      allow = [{
        protocol = "TCP"
        ports = ["22", "443"]
      },
      {
        protocol = "icmp"
    }]
    },
  ]
}

# Add a subnet for FortiGates to the hub network created in hub-and-spokes.tf
#
resource "google_compute_subnetwork" "fgt_int" {
    name = "${var.prefix}-hub-fgt"
    ip_cidr_range = var.fgt_subnet_cidrs["int"]
    region = var.fgt_region
    network = module.hub_network.network_id
}

module "fgtha" {
    source = "git::github.com/fortinet/terraform-google-fgt-ha-ap-lb"

    prefix = var.prefix
    region = var.fgt_region
    image = {
        version = "7.4"
        
        # By default this template deploys PAYG images, uncomment the following line if you 
        # prefer to use BYOL or FortiFlex licenses

        # licensing = "byol"
    }
    subnets = [
        one(module.fgt_ext_network.subnets_names),
        google_compute_subnetwork.fgt_int.name,
        one(module.fgt_hamgmt_network.subnets_names)
    ]
    admin_acl = var.fgt_admin_acl

    # These routes will be added to the internal VPC. Defaults to "0.0.0.0/0" which routes 
    # all traffic leaving spoke VPCs via FortiGate (with exception of Google's privately used 
    # public ranges, eg. used by IAP or classic ALB).
    routes = {
        default = "0.0.0.0/0"
    }
    # Each peered network (or their supernet) needs to be added to FortiGates routing table
    # For convenience let's also automatically add firewall address objects for spoke VPCs
    # Mind that updating this deployment with new spokes will not update FGT configuration.
    fgt_config = <<EOT
      config router static
        %{ for cidr in values(var.spokes)[*].ip_cidr_range ~}
        edit 0
        set dst ${cidr}
        set device port2
        set gateway ${google_compute_subnetwork.fgt_int.gateway_address}
        next
        %{ endfor ~}
      end

      config firewall address
        %{ for spoke in keys(var.spokes) ~}
        edit ${spoke}
        set type dynamic
        set sdn "gcp"
        set filter "Network=${var.prefix}-${spoke}"
        next
        %{ endfor ~}
      end
    EOT

    # Having networks created in the same terraform as FGTs, we need to add them to depends_on
    # to delay pulling data inside module (this module requirement, not a general rule)
    depends_on = [
        module.fgt_ext_network,
        module.fgt_hamgmt_network,
        module.hub_network
    ]
}