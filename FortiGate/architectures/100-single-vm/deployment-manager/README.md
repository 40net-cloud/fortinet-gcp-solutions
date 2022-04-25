# Deploying single FortiGate VM with Deployment Manager

## Templates
### [singlevm-no-template.yaml](singlevm-no-template.yaml)

This configuration file includes plain YAML declaration of a FortiGate instance and a log disk. It will not create any additional resources and is provided as a basis for anyone wishing to create their own templates. As it references VPC Networks and subnets, they need to be created before deploying the config file - *this file will NOT deploy without modifications*. Custom route and cloud firewall rules need to be added manually.

### [singlevm2.jinja](../../../modules-dm.singlevm2.jinja)
This file provides a highly flexible template for deploying a single FortiGate instance with all additional necessary resources and is meant to be included in customer Infrastructure-as-Code. singlevm2 can deploy FortiGate instance with any (1-8) number of network interfaces and is used in some other architectures provided in this repository.

Created resources:
- 1 FortiGate VM instance (BYOL or PAYG, depending on license.type property)
- 1 log disk
- external IP addresses - for each externalIP and additionalExternalIPs
- forwarding rules - for each additionalExternalIPs entry
- target instance - if at least one additionalExternalIPs entry exists
- cloud firewall rules - allowing all traffic to FGT VM
- custom route towards port2 of FGT VM

Required configuration:
- region
- list of networks to connect FGT VM to

For full list of supported properties, please consult the [schema file](../../../modules-dm/singlevm2.jinja.schema).

## Examples
![](https://lucid.app/publicSegments/view/0d34e874-914a-473e-a9f9-2c6464f1e1dd/image.png)

- [config-dhcp.yaml](config-dhcp.yaml) - very basic example of deploying with 2 automatically configured (DHCP) network interfaces and PAYG license
- [config-byol.yaml](config-byol.yaml) - 2-nic instance with BYOL license pulled from a license file and NICs configured statically for empty subnets. Remember to modify to point to your own lic file
- [config-protocolforwarding.yaml](config-protocolforwarding.yaml) - BYOL licensing, statically configured NICs and 3 public IPs forwarded using protocol forwarding. Additionally this template shows how you can provision FortiGate configuration during deployment and manually define prefix for resource names. Remember to modify to point to your own lic file
- [config-8-nic.yaml](config-8-nic.yaml) - 8-nic instance with BYOL license. Remember to modify to point to your own lic file

## How to deploy
Deployment manager configs (YAML) can be deployed using the *gcloud* command line tool.

1. Open Cloud Shell
1. clone the git repository (it will also work if you download only a single yaml file and change the link in *imports* section to be an absolute URL of the file on GitHub)
1. deploy using
`gcloud deployment-manager deployments create my-fgt-poc --config config-dhcp.yaml`

### See also:
- [Getting started with Deployment Manager](../../../../howto-dm.md)
