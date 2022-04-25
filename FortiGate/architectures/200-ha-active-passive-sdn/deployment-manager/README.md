# Deploying SDN Connector-based Active-Passive FortiGate cluster with Deployent Manager
This template deploys an Active-Passive HA cluster of 2 FortiGate instances together with the required cloud resources. The cluster is preconfigured with the FGCP configuration synchronization, GCP Fabric Connector, and proper HA configuration for external IP and route failover.

HA multi-zone deployments provide 99.99% Compute Engine SLA vs. 99.5-99.9% for single instances. See [Google Compute Engine SLA](https://cloud.google.com/compute/sla) for details.

This template currently supports only 4-nic deployments. You will have to modify the .jinja file to deploy with more NICs.

Template file: [modules/fgcp-ha-ap-sdn.jinja](../modules/deployment-manager/fgcp-ha-ap-sdn.jinja)
Schema file: [modules/fgcp-ha-ap-sdn.jinja.schema](../modules/deployment-manager/fgcp-ha-ap-sdn.jinja.schema)


## Prerequisites
1. Two VPC Networks created for external and protected roles
1. Two empty subnets created in the external and protected VPCs.

## Example configs

- [SDN-based Active-Passive HA - minimal](ha-ap-sdn-minimal.yaml) - smallest possible config to deploy an FGCP Ha cluster
- [SDN-based Active-Passive HA - BYOL](ha-ap-sdn-byol.yaml) - check this one to see how you can deploy a BYOL FGT cluster and license it during provisioning
- [SDN-based Active-Passive HA - full](ha-ap-sdn-full.yaml) - all the properties you can use with this template (it's always a good idea to consult the schema file)
- [SDN-based Active-Passive HA](ha-ap-sdn_multiip-with-server.yaml) - using multiple public IPs, includes a demo server

## Post-deployment Steps
After your firewalls are deployed, connect to the primary instance and change the default password. The initial password is set to the primary instance ID.
