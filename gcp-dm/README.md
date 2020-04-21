# Fortigate GCP templates
This repository hosts GCP Deployment Manager templates for Fortinet solutions.

## Solutions available
1. [Peered Security Hub](hub) - security hub infrastructure using GCP native VPC Network peering. Deploys with an Active-Passive HA cluster.
1. [Active-Passive HA cluster](fortigate/ha-ap.md) - active-passive cluster with one public IP and SDN Connector based failover
1. [Active-Passive HA cluster with Load Balancer](fortigate/ha-ap-elb.md) - active-passive cluster with support for multiple Public IPs
