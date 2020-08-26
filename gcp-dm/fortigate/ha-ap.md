# Active-Passive HA FortiGate Pair with Fabric Connector Failover
This template can be used to deploy an Active-Passive HA cluster of 2 Fortigate instances together with the required cloud resources. The cluster is preconfigured with the FGCP configuration synchronization, GCP Fabric Connector, and proper HA configuration for external IP and route failover.

This architecture is suitable for deployments where only a single Public IP is required.

## Design
As unicast FGCP clustering of FortiGate instances requires dedicated heartbeat and management NICs, 2 additional VPC Networks need to be created (or indicated in configuration file). This design features 4 separate VPCs for external, internal, heartbeat and management NICs. Both instances are deployed in separate zones indicated in **zones** property to enable GCP 99.99% SLA.

Additional resources deployed include:
- default route for the internal VPC Network pointing to the internal IP of primary Fortigate - this route will be re-written using Fabric Connector during failover to direct outbound traffic from internal network via the active instance. More granular routing can be deployed by template using the routes property
- 3 external IPs - one floating IP for incoming traffic from Internet and 2 management IPs
- Cloud Router/Cloud NAT service is used to allow outbound traffic from port1 of secondary FortiGate instance (e.g. for license activation)

![A-P HA Diagram](https://www.lucidchart.com/publicSegments/view/9fb2009b-32fa-4404-9009-4eb4529c988c/image.png)

## Prerequisites
1. Two VPC Networks created for external and protected roles
1. Two empty subnets created in the external and protected VPCs.

## Failover automation
Deployed Fortigates integrate with GCP fabric using an SDN Connector. Upon failover 2 actions are performed:
- named route is switched to the IP of the now active node
- named external IP is re-assigned to the now active node

## Dependencies
This template uses [singlevm.jinja](singlevm.md) template and helpers in utils directory.

## How to deploy
See [README](README.md) for details on how to deploy this template and on available parameters.

See [ha-ap-sdn.yaml](examples/ha-ap-sdn.yaml) in [examples](examples) directory for a basic configuration file to start with.

## Post-deployment Steps
After your firewalls are deployed, connect to the primary instance and change the default password. The initial password is set to the primary instance ID.

## See also
[Other Fortigate deployments](./README.md)
