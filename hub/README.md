# Peered Security Hub VPC Network with Fortigate P-A HA Pair
### GCP Deployment Manager template

# Introduction

# Design
GCP limitations related to deployment of multi-NIC instances make the [usual architecture](https://cloud.google.com/solutions/best-practices-vpc-design#multi-nic) for deploying firewalls very static and costly (a classic 3-tier application would require an 8-core FGT instances). Peered Security Hub architecture provides flexibility of securing up to 25 segments using standard VM04 instances.

Hub-and-spoke design puts firewalls in the hub VPC Network and connects all VPC Networks to be inspected for traffic using peering. Default route defined in the Hub is propagated to the spokes using exportCustomRoutes/importCustomRoutes properties set on peerings (hub exports, spoke imports), thus enforcing traffic flow between spoke VPCs and from spokes to the Internet to be routed via firewalls.

![Peered Security Hub diagram](https://www.lucidchart.com/publicSegments/view/0d77291e-9bd6-4c71-a2cd-ba5a85de61bd/image.png)

## Deployed resources
- 2 Fortigate VMs - clustered, with networking, GCP Connector and spoke network address objects preconfigured
- 1 static public IP bound to port1 of fgt1 instance
- 2 ephemeral public IP addresses bound to port3 of both Fortigate VMs
- default route for Fortigates (tag-based)
- default route for all other instances in hub VPC (gets imported to spokes)
- Hub VPC
- HA sync VPC
- management VPC
- spoke VPCs
- peerings from Hub to spokes and back
- firewall rules to allow traffic to VPCs
- firewall rule to allow HA communication between FGT instances


### Note:
Current version of the template deploys a single NIC for data path without splitting it to internal and external network. Modification of this design will follow soon.

# Licensing
This template supports both PAYG and BYOL licensing (with PAYG as default setting). To deploy a BYOL version, add a `license` property to your config file with following values:
      type: byol
      lic1: path-to-license-file-for-master
      lic2: path-to-license-file-for-slave

# How to Deploy
This template set uses Google Cloud [Deployment Manager](https://cloud.google.com/deployment-manager) to deploy all the resources.

After downloading and customizing the configuration file (config.yaml) to your needs, run the command below to deploy
    gcloud deployment-manager deployments create [deployment name] --config config.yaml

## Customizing the Deployment
There's a number of configuration options available directly in the `config.yaml` file without changing the DM templates. For the full list and default values, please consult fortigate-security-hub.jinja.schema. The most important are:

#### `license`
Describes licensing type (payg or byol) and provides license files for byol deployment
Default value:
    license:
      type: payg

#### `region`, `zone1` and `zone2`
Define where the Fortigate VMs should be deployed to (no default values).

#### `fgtServiceAccount`
Indicates service account to be used for the Fortigate instances. Fortigate needs access to GCP API to switch routing and public IP during HA failover and acquires all the data automatically from the cloud fabric. If not set, Fortigate instances will be using the default Compute account.

## Naming Convention
By default all deployed resources are prefixed with the deployment name (e.g. my-deployment-fgt1, my-deployment-peering-spoke1-hub). To change the prefix, modify the prefix variable at the top of `fortigate-security-hub.jinja` template.

## Post-deployment Steps
No manual post-deployment steps are needed anymore. Import/export routes is fixed in this version