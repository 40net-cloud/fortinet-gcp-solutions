# Single VM Fortigate deployment
Basic 2-NIC design for north-south inspection using a single Fortigate VM instance.

## Design

![](https://www.lucidchart.com/publicSegments/view/ef2af385-2974-4120-a37d-3cbf676e8b96/image.png)

## Prerequisites
1. Two VPC Networks created for external and protected roles
1. Two empty subnets created in the external and protected VPCs

## Resources Created
- Static Public IP address
- Fortigate VM instance
- 2x VPC Network
- 2x Subnetwork
- 2x Custom Routes
- 2x Cloud Firewall Rules

## How to deploy
See [README](README.md) for details on how to deploy this template and on available parameters.

## Post-deployment Steps
After your firewall is deployed, connect to it and change the default password.

## Note
This template does NOT create any networks.
