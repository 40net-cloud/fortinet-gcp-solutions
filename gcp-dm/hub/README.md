# Peered Security Hub VPC Network with Fortigate P-A HA Pair
### GCP Deployment Manager template

# Introduction
GCP limitations related to deployment of multi-NIC instances make the [usual architecture](https://cloud.google.com/solutions/best-practices-vpc-design#multi-nic) for deploying firewalls very static and costly (a classic 3-tier application would require an 8-core FGT instances). Peered Security Hub architecture provides flexibility of securing up to 25 segments using standard VM04 instances.

# Design
Hub-and-spoke design puts firewalls in the hub VPC Network and connects all VPC Networks to be inspected for traffic using peering. Default route defined in the Hub is propagated to the spokes using exportCustomRoutes/importCustomRoutes properties set on peerings (hub exports, spoke imports), thus enforcing traffic flow between spoke VPCs and from spokes to the Internet to be routed via firewalls.

![Peered Security Hub diagram](https://www.lucidchart.com/publicSegments/view/0d77291e-9bd6-4c71-a2cd-ba5a85de61bd/image.png)

Note that the Security Hub design focuses on the cloud architecture, while the Fortigate part is flexible - you can use any building block available in this repository by changing the import path in your configuration file (compare [config.yaml](config.yaml) and [config-elb.yaml](config-elb.yaml))

## Deployed resources
- 2 Fortigate VMs - clustered, with networking, GCP Connector and spoke network address objects preconfigured
- 1 static public IP bound to port1 of fgt1 instance
- 2 ephemeral public IP addresses bound to port3 of both Fortigate VMs
- default route to Internet for Fortigates
- default route for all other instances in hub VPC (gets ex/imported to spokes)
- Internal Hub VPC Network
- External VPC Network
- HA sync VPC Network
- management VPC Network
- spoke VPCs
- peerings from Internal Hub to spokes and back
- firewall rules to allow traffic to VPCs
- firewall rule to allow HA communication between FGT instances


# Licensing
This template supports both PAYG and BYOL licensing (with PAYG as default setting). To deploy a BYOL version, add a `license` property to your config file with following values:
```
license:
  type: byol
  lic1: path-to-license-file-for-master
  lic2: path-to-license-file-for-slave
```
and add license files to configuration imports. See [config-byol.yaml](config-byol.yaml) for an example.

For PAYG deployment use `type: payg` or simply remove the `license:` definition to fall back to the defaults.

# How to Deploy
This template set uses Google Cloud [Deployment Manager](https://cloud.google.com/deployment-manager) to deploy all the resources.
You can use any machine with gcloud cli tool installed to deploy the template (e.g. [Cloud Shell](https://cloud.google.com/shell/docs/using-cloud-shell)).

1. Download the example configuration file to your deployment machine:
```
wget https://raw.githubusercontent.com/40net-cloud/fortinet-gcp-solutions/master/gcp-dm/hub/config.yaml
```
1. Edit the properties section to reflect your desired architecture and licensing (see below section for details)
1. If you're using BYOL licensing, copy the .lic files to same directory as your config.yaml file and refer the files in configuration
1. Create the deployment base on your configuration:
```
gcloud deployment-manager deployments create [deployment name] --config config.yaml
```
1. Succesfull deployment will finish with printing management IP addresses of both Fortigate instances. Connect to master to configure your admin password (by default Masters instance ID).

## Customizing the Deployment
There's a number of configuration options available directly in the `config.yaml` file without changing the DM templates. For the full list and default values, please consult [fortigate-security-hub.jinja.schema](fortigate-security-hub.jinja.schema). The most important are:

#### `license`
Describes licensing type (payg or byol) and provides license files for byol deployment

#### `region`, `zone1` and `zone2`
Define where the Fortigate VMs should be deployed to (no default values).

#### `fgtServiceAccount`
Indicates service account to be used for the Fortigate instances. Fortigate needs access to GCP API to switch routing and public IP during HA failover and acquires all the data automatically from the cloud fabric. If not set, Fortigate instances will be using the default Compute account.

#### `hubNetworks`
An object describing 4 VPC Networks deployed as the hub (internal, external, hasync, and management). If you're ok with the default 10.0.0.0/24 IP space shared by these 4 by default, leave it to defaults.

#### `spokeNetworks`
An array describing all spoke networks to be created and peered with VPC. Check the example config.yaml for the format.

#### Architecture
You can deploy an HA cluster or HA cluster with ELB in this template. Just change the import section of the configuration file to reflect your desired architecture (compare import sections of [config.yaml](config.yaml) and [config-elb.yaml](config-elb.yaml) for more insight).

## Naming Convention
By default all deployed resources are prefixed with the deployment name (e.g. my-deployment-fgt1, my-deployment-peering-spoke1-hub). To change the prefix, modify the prefix variable at the top of `fortigate-security-hub.jinja` template.

# What next? Post-deployment Steps
1. Connect to the Master Fortigate instance and set your administrator password. Wait for the cluster to come into full sync
2. Connect to Slave Fortigate to make sure it is properly licensed and in sync. In case of HA sync problems, refer to [Fortinet documentation](https://kb.fortinet.com/kb/documentLink.do?externalID=FD36494)

