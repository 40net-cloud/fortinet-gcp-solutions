# Peering-based hub and spoke

This directory contains an example template deploying a [Peered Security Hub](../README.md) architecture. It will deploy the following components:

**hub-and-spoke.tf**:
- hub VPC network
- 2 spoke VPC networks and subnets
- VPC peerings for hub and spokes

**fgt.tf**:
- external FortiGate VPC network and subnet
- FortiGate VPC network dedicated for HA and management
- FortiGate HA cluster (active-passive)


### FortiGates configuration

FGCP-based active-passive cluster, probe responders and GCP SDN connector are configured by the module. Additional configuration passed to the module using `fgt_config` input variable configures static routes and firewall address objects for each spoke.

***NOTE: by defalut FortiGates will deploy with PAYG licenses, change `module.fgtha.image.licensing` property to use BYOL. See licensing examples in the module [examples](https://github.com/fortinet/terraform-google-fgt-ha-ap-lb/tree/main/examples) directory.***

### Variables

The template deploys with the default variable values, but feel free to override the defaults:

- **prefix** - string prepended to names of all the resources created by this template. Prefix cannot be empty
- **spokes** - describes spoke VPCs and subnets properties. Each example spoke VPC will be created with a single subnet
- **fgt_region** - region in which to deploy FortiGate cluster
- **fgt_admin_acl** - ACL to restrict access to FortiGates management interface
- **fgt_subnet_cidrs** - 3 CIDRs of subnets directly connected to FortiGate cluster (ext, int, hamgmt - for external, hub and management networks connected to port1, port2 and port3 respectively)

### How to deploy

1. copy contents of this directory to your machine or to cloud shell:
```
git clone https://github.com/40net-cloud/fortinet-gcp-solutions.git
cd FortiGate/architectures/300-peered-security-hub/terraform
```
2. make sure you're logged in using gcloud or add `provider "google"` and `provider "google-beta"` blocks with proper authentication configuration to the main.tf file
3. if using gloud authentication and not deploying using Cloud Shell, add environment variable with project ID:
```
export GOOGle_PROJECT=your-project-id
```
4. initialize terraform
```
terraform init
```
5. deploy (you will be presented with list of ~50 resources and asked to confirm deployment)
```
terraform apply
```

### Clean-up

After you have finished exploring this example remember to delete its resources:

```
terraform destroy
```