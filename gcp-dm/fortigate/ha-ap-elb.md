# Active-Passive HA Fortigate cluster with External Load Balancer
This template deploys a standard A-P HA cluster of 2 Fortigate instances behind an External Network Load Balancer. This architecture is suitable for deployments where multiple Public IPs are needed.

# NOTE: this template is obsoleted by [HA in LB Sandwich](ha-ap-elbilb.md) design

![A-P HA Diagram](https://www.lucidchart.com/publicSegments/view/346f8206-c719-43df-bdb6-defdb694aced/image.png)

## Failover automation
Service IP addresses defined in properties.publicIPs are used as frontends for forwarding rules. Target Pool is using HTTP probe at port 8008 to determine the active Fortigate peer. Upon failover active peer is detected and starts receiving the traffic.

Additionally, deployed Fortigates integrate with GCP fabric using an SDN Connector. Upon failover 2 actions are performed:
- named route is switched to the IP of the now active node
- named external IP is re-assigned to the now active node

## Created resources
This template creates following resources:
- Static public IP Addresses
- 2x log disk
- 2x VM instance of Fortigate
- Cloud Firewall rules (x4)
- Routes (x2)
- HTTP Health Check
- Load Balancer Target Pool
- Forwarding Rules (2 for each public IP: TCP:1-65535 and UDP:1-65535)

## Dependencies
This template uses helpers in utils directory.

## Limitations
IP addresses managed by GCP external network load balancer support TCP and UDP protocols only. If you need to use any other protocols, use the additional IP floating address assigned directly to the port1 of active Fortigate instance.

## Post-deployment steps
After successful deployment perform the following steps:
1. Connect to FGT1 instance and change the default password (by default it's set to the instance id of primary instance and is included in config for your convenience)
1. For PAYG only: after confirming proper licensing and initial syncing of Fortigate peers remove ephemeral public IP from nic0 of fgt2 instance

## Post-deployment modifications
Note that adding and removing Public IP addresses from the frontend configurations requires configuration changes on Fortigate nodes (adding secondary IP for port1 and allowing probe traffic). Changing the Deployment Manager configuration file will add/remove IP addresses in GCP but *will not* automatically change Fortigate configuration. Please, remember to commit required changes manually.

## See also
[Other Fortigate deployments](./README.md)
