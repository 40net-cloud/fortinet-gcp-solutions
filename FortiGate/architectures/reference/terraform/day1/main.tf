# Create new network and some sample workload inside
data "google_compute_subnetwork" "wrkld_demo" {
  self_link = var.wrkld_demo_subnet
}

module "sample-wrkld-vm" {
  source = "../../../../modules-tf/utils/sample-wrkld-vm"
  wrkld_subnet = data.google_compute_subnetwork.wrkld_demo.self_link
}

# Connect the workload VPC to FortiGate Security Hub
module "peer1" {
  source = "../../../../modules-tf/usecases/spoke-vpc"

  day0 = data.terraform_remote_state.base.outputs
  vpc_name = split( "/", data.google_compute_subnetwork.wrkld_demo.network)[length(split( "/", data.google_compute_subnetwork.wrkld_demo.network))-1]
  vpc_project = data.google_compute_subnetwork.wrkld_demo.project
}

# Enable inbound connections and redirect port 80 to some workload
module "inbound" {
  source     = "../../../../modules-tf/usecases/inbound-ns"

  day0       = data.terraform_remote_state.base.outputs
  srv_name   = "service1"
  targets    = [
 {  ip   = module.sample-wrkld-vm.network_ip,
    port = 80 },
  ]

  # Manual dependency is needed here because of GCP issues with parallel peering and routing
  depends_on = [
    module.peer1
  ]
}

# Output the external IP address of new service
output public_ip {
  value     = module.inbound.public_ip
}

# Enable outbound connections
module "outbound" {
  source    = "../../../../modules-tf/usecases/outbound-ns"

  day0      = data.terraform_remote_state.base.outputs
  elb       = module.inbound.elb_frule
}
