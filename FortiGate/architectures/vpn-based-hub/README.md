# VPN-based hub and spoke demo

This terraform module leverages VPN-based hub-and-spoke architecture described [here](https://cloud.google.com/architecture/deploy-hub-spoke-vpc-network-topology#vpn). Routing is handled using policy-based routes. Note it is a demo and some values as well as licensing approach are hard-coded.

## VPN-based approach vs. peering-based

Advantages:

- unlimited spokes
- support for PSC

Disadvantages:

- limited throughput
- high cost of VPN tunnels

## Providers configuration / how to use

This module uses google, google-beta and fortiflex providers. For Flex provider the credentials are pulled from the Google secret manager and you need to indicate the names of the secrets in variables or change fgt.tf (lines 73-85)