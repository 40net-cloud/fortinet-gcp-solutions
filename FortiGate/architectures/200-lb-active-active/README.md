# FortiGates in Load Balanced Active-Active group
Active-Active designs base on multiple appliances actively processing streams of data. In the public cloud this architecture differs from active-active on-prem deployments of physical FortiGates because of the cloud network limitations. Unlike on-prem, you cannot use FGCP protocol (unicast FGCP supports only 2 peers in active-passive configuration) and you're left with FGSP.

## Flow symmetry and UTM scanning
In order to effectively inspect network traffic for threats, FortiGates need to process traffic flowing in both directions (both the packets from client to server and the response packets from server to client). While all load balancers in GCP are part of SDN, not all of them can cooperate to maintain flow symmetry. Below is the summary of each case:

#### Outbound connections - VPC to Internet
In this case all connections are ALWAYS source-natted. This means the return packet will always go to the proper firewall instance maintaining flow symmetry.

#### Internal connections - VPC-to-VPC
Provided VPCs of both client and server route to FortiGate instances via Internal Load Balancers, all load balancers deployed after Jun 22nd, 2021 have symmetric hashing enabled - a feature introduced specifically to provide flow symmetry to active-active NVA deployments. See [here](https://cloud.google.com/load-balancing/docs/internal/ilb-next-hop-overview#ilb-nh-multi-nic) for more details.

#### Internet-to-VPC
As of today, external forwarding rules do NOT support *symmetric hashing* feature, thus flow asymmetry can (and will) occur. To circumvent any problems you can either enable SNAT for all connections (for HTTP traffic you can inject X-Forwarded-For header to pass the real client IP) or use the [L3 UTM scan feature introduced in FortiGate 6.4](https://docs.fortinet.com/document/fortigate/6.4.0/new-features/324430/support-utm-inspection-on-asymmetric-traffic-on-l3).

Note that session and UTM syncing using FGSP does NOT support configuration sync. For synchronizing firewall policies across FGSP peers Fortinet recommends using a FortiManager.

## Design
While this design can be deployed with multiple internal load balancers on multiple interfaces, the standard deployment includes one external load balancer connected to port1 and one internal load balancer connected to port2. For best performance - especially when leveraging L3 UTM scan feature - we recommend using a dedicated port3 for FGSP communication.

![Active-Active Details diagram](https://lucid.app/publicSegments/view/8e53be59-2ff5-4bb3-90aa-0d2ed6833dad/image.png)

## How to deploy
- [with Deployment Manager](deployment-manager/)
