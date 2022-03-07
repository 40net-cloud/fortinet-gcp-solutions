# FortiGate Reference Architure for Google Cloud
## Base module (day0)

This configuration deploys a cluster of FortiGates into GCP and connects them to 4 subnets. The subnets might be created before and their **names** be provided to the fgcp-ha-ap-lb module in `subnets` variable, or the VPCs and subnets can be created as part of this configuration (eg. using sample-networks module). Day0 "base" deployment does not offer any network functionality and is simply a foundation required by all Day1 modules.

The design is using a "load balancer sandwich" design with ILBs (Internal Load Balancers) used as custom route next-hop for detecting currently active instance and routing traffic through it. Using load balancers guarantees fast failover time (~10 secs.) and stateful failover (currently in preview). Base configuration includes the ILB on trusted side of the cluster as it will be necessary for all use-cases (except for NCC integration).

### Prerequisites
FortiGate uses its External Fabric Connector (a.k.a. SDN Connector) to support firewall policies based on GCE metadata instead of just IP addresses. In order for Connector to function, the FortiGate instances must be given access to all needed projects. It is highly recommended to use the minimum set of privileges by creating a custom role and a service account using `service_account_create.sh` script and providing service account name in `service_account` module variable. Otherwise the default GCE account will be used.

You should create VPC networks and subnets in the region where you plan to deploy FortiGates before or as a part of day0 configuration. Make sure the `subnets` argument passed to the `fgcp-ha-ap-lb` module points to the proper subnets. You will need 4 VPCs connected to 4 different network interfaces of your FortiGate instances:
- port1 (nic0) - external (untrusted) network
- port2 (nic1) - internal (trusted) network
- port3 (nic2) - FGCP hertbeat/sync interface
- port4 (nic3) - dedicated management interface

*Note: due to the way Google Cloud networking works it is NOT possible to deploy a FortiGate VM instance with NICs connected to different subnets of the same VPC.*

### Contents
Following resources will be created:
- FortiGate VM instances
- zonal unmanaged instance groups
- backend service
- internal load balancer
- default (0.0.0.0/0) custom route with ILB as the next hop
- external IP addresses to be used for management
- set of reserved internal addresses

## How to deploy
1. Run service_account_create.sh to create new service account and IAM role
1. If you want to use existing subnets: edit main.tf to point to them in `subnets` argument of `fortigates` module
1. If you want to create sample subnets: uncomment reference to `sample_networks` in `main.tf`
1. Add your FortiGate license files (*.lic) to the day0 directory and update file names in `license_files` argument for `fortigate` module in `main.tf` file
1. Use `./deploy.sh` to initialize and deploy the configuration to your default project and region or follow the usual terraform flow:
    1. run `terraform init`
    1. run `terraform plan -out day0.plan` and review the list of resources to be created
    1. run `terraform apply day0.plan` to create resources

After everything is deployed you can connect to the management NIC of primary FortiGate using SSH or HTTPS (on standard ports) via the first IP address printed in `fgt-mgmt-eips`. Log in as **admin**, the initial password is set to primary instance id (for convenience visible as `default_password` output).

## How to clean up
1. Make sure you do not have any day1 configuration deployed, eg. by going to day1 and running `terraform show` (you should see empty output)
1. go back in day0 run `terraform destroy`
