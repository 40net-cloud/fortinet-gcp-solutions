/*
module "peer1" {
  source = "../modules/usecases/spoke-vpc"

  day0 = data.terraform_remote_state.base.outputs
  vpc_name = "bm-spoke1"
  vpc_project = "forti-emea-se"
}
/*
module "sample-wrkld-vm" {
  source = "../modules/utils/sample-wrkld-vm"

  wrkld_subnet = "https://www.googleapis.com/compute/v1/projects/forti-emea-se/regions/europe-west6/subnetworks/bm-spoke1-sb"
}
*/

module "inbound" {
  source = "../modules/usecases/inbound-ns"

  day0 = data.terraform_remote_state.base.outputs
  srv_name = "service1"
  targets = [
# {  ip = module.sample-wrkld-vm.network_ip,
#    port = 80 },
  ]
}

output public_ip {
  value = module.inbound.public_ip
}

module "outbound" {
  source = "../modules/usecases/outbound-ns"

  day0 = data.terraform_remote_state.base.outputs
  elb = module.inbound.elb_frule
}
