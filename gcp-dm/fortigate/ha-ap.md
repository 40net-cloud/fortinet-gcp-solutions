# Active-Passive HA Fortigate cluster with SDN Connector
This template deploys a standard A-P HA cluster of 2 Fortigate instances. This architecture is suitable for deployments where a single Public IP is needed.

![A-P HA Diagram](https://www.lucidchart.com/publicSegments/view/9fb2009b-32fa-4404-9009-4eb4529c988c/image.png)

## Failover automation
Deployed Fortigates integrate with GCP fabric using an SDN Connector. Upon failover 2 actions are performed:
- named route is switched to the IP of the now active node
- named external IP is re-assigned to the now active node

## Dependencies
This template uses [singlevm.jinja](singlevm.md) template and helpers in utils directory.

## See also
[Other Fortigate deployments](./README.md)
