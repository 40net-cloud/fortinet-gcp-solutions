# Single VM Fortigate deployment
Basic 2-NIC design for north-south inspection using a single Fortigate VM instance. It is a good design to start exploring the capabilities of the Fortigate next-generation firewall. The instance will receive all traffic from Internet sent to its external IP and can forward it to any resources in the internal network. Traffic from internal network will be sent to the internal NIC of appliance using the default route created during the deployment.

Limitations:
- subject to lower 99.5% SLA
- the template supports only a single external IP, but more can be added after the deployment using [protocol forwarding](https://cloud.google.com/compute/docs/protocol-forwarding)

## Design

![](https://www.lucidchart.com/publicSegments/view/ef2af385-2974-4120-a37d-3cbf676e8b96/image.png)

## Prerequisites
1. Two VPC Networks created for external and protected roles
1. Two subnets created in the external and protected VPCs. Although not obligatory, it is recommended that the subnets are empty and their CIDR ranges are provided in configuration file enabling the template to assign static internal IPs to the firewall NICs. Route created for protected internal network will point to instance internal IP address and will stop working if it changes.

## Resources Created
- Static Public IP address
- Fortigate VM instance
- 2x Custom Routes
- 2x Cloud Firewall Rules

## How to deploy
See [README](README.md) for details on how to deploy this template and on available parameters.

See [singlevm.yaml](examples/singlevm.yaml) in [examples](examples) directory for a typical configuration file to start with.

## Post-deployment Steps
After your firewall is deployed, connect to it and change the default password. The initial password is set to the instance ID.

## Note
This template does NOT create any networks.
