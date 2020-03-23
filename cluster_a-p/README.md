# Active-Passive HA Fortigate cluster
This template deploys a standard A-P HA cluster of 2 Fortigate instances.

## Failover automation
Deployed Fortigates integrate with GCP fabric using an SDN Connector. Upon failover 2 actions are performed:
- named route is switched to the IP of the now active node
- named external IP is re-assigned to the now active node

## Dependencies
This template uses helpers in utils directory.