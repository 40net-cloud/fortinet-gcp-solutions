provider "google" {
  version     = "3.20.0"
  credentials = file(var.credentials_file_path)
  project     = var.project
  region      = var.region
  zone        = var.zone
}

module "random" {
  source = "../../modules-tf/random-generator"
}

module "vpc" {
  source = "../../modules/vpc"
  # Pass Variables
  name = var.name
  vpcs = var.vpcs
  # Values fetched from the Modules
  random_string = module.random.random_string
}

module "subnet" {
  source = "../../modules-tf/subnet"

  # Pass Variables
  name         = var.name
  region       = var.region
  subnets      = var.subnets
  subnet_cidrs = var.subnet_cidrs
  # Values fetched from the Modules
  random_string = module.random.random_string
  vpcs          = module.vpc.vpc_networks
}

module "firewall" {
  source = "../../modules-tf/firewall"

  # Values fetched from the Modules
  random_string = module.random.random_string
  vpcs          = module.vpc.vpc_networks
}

module "route" {
  source = "../../modules-tf/route"

  # Pass Variables
  name        = var.name
  next_hop_ip = var.next_hop_ip
  # Values fetched from the Modules
  random_string       = module.random.random_string
  private_vpc_network = module.vpc.vpc_networks[1]
  # Route depends on the Private_Subnet
  route_depends_on = module.subnet.subnets[1]
}

module "static-ip" {
  source = "../../modules-tf/static-ip"

  # Pass Variables
  name = var.name
  # Values fetched from the Modules
  random_string = module.random.random_string
}

module "instances" {
  source = "../../modules-tf/instances"

  # Pass Variables
  name               = var.name
  service_account    = var.service_account
  zone               = var.zone
  machine            = var.machine
  image              = var.image
  license_file       = var.license_file
  license_file_2     = var.license_file_2
  active_port1_ip    = var.active_port1_ip
  active_port1_mask  = var.active_port1_mask
  active_port2_ip    = var.active_port2_ip
  active_port2_mask  = var.active_port2_mask
  active_port3_ip    = var.active_port3_ip
  active_port3_mask  = var.active_port3_mask
  active_port4_ip    = var.active_port4_ip
  active_port4_mask  = var.active_port4_mask
  passive_port1_ip   = var.passive_port1_ip
  passive_port1_mask = var.passive_port1_mask
  passive_port2_ip   = var.passive_port2_ip
  passive_port2_mask = var.passive_port2_mask
  passive_port3_ip   = var.passive_port3_ip
  passive_port3_mask = var.passive_port3_mask
  passive_port4_ip   = var.passive_port4_ip
  passive_port4_mask = var.passive_port4_mask
  mgmt_gateway       = var.mgmt_gateway
  mgmt_mask          = var.mgmt_mask
  # Values fetched from the Modules
  random_string         = module.random.random_string
  public_vpc_network    = module.vpc.vpc_networks[0]
  private_vpc_network   = module.vpc.vpc_networks[1]
  sync_vpc_network      = module.vpc.vpc_networks[2]
  mgmt_vpc_network      = module.vpc.vpc_networks[3]
  public_subnet         = module.subnet.subnets[0]
  private_subnet        = module.subnet.subnets[1]
  sync_subnet           = module.subnet.subnets[2]
  mgmt_subnet           = module.subnet.subnets[3]
  static_ip             = module.static-ip.static_ip
  public_subnet_gateway = module.subnet.public_subnet_gateway_address
}
