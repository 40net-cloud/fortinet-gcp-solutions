# Active-Passive HA Fortigate cluster in LB Sandwich
This template deploys 2 Fortigate instances in an Active-Passive HA cluster between two load balancers ("load balancer sandwich" pattern). LB Sandwich design enables use of multiple public IPs and provides faster, configurable failover times. HA multi-zone deployments provide 99.99% Compute Engine SLA.

## Diagram
As unicast FGCP clustering of FortiGate instances requires dedicated heartbeat and management NICs, 2 additional VPC Networks need to be created (or indicated in configuration file). This design features 4 separate VPCs for external, internal, heartbeat and management NICs. Both instances are deployed in separate zones indicated in **zones** property to enable GCP 99.99% SLA.

Additional resources deployed include:
- default route for the internal VPC Network pointing to the internal load balancer rule
- external IPs - by default one floating IP for incoming traffic from Internet and 2 management IPs, to add more external IPs simply list them in the **publicIPs** property
- Cloud Router/Cloud NAT service is used to allow outbound traffic from port1 of secondary FortiGate instance (e.g. for license activation)

![ELBILB Sandwich diagram](https://app.lucidchart.com/publicSegments/view/b1ee079a-3c64-4e75-acb7-a42e3b6f8982/image.png)

## Deployed Resources
- 2 Fortigate VM instances with 4 NICs each
- 2 VPC Networks: heartbeat and management (unless provided)
- External Load Balancer
    - External addresses
    - Target pool
    - Legacy HTTP Health Check
    - 2 Forwarding Rules for each IP (UDP and TCP)
- Internal Load Balancer
    - 2 unmanaged Instance Groups (one in each zone)
    - Backend Service
    - Internal Forwarding Rule (using ephemeral internal IP)
    - HTTP Health Check
    - route(s) via Forwarding Rule
- Cloud NAT

## Prerequisites and Requirements
You must create the external and protected VPC networks before using this template.

All VPC Networks already created before deployment and provided to the template using `networks.*.vpc` and `networks.*.subnet` properties, they SHOULD have first 2 IP addresses available for Fortigate use. Addresses are assigned statically and it's the responsibility of administrator to make sure they do not overlap.

## Dependencies
This template uses [singlevm.jinja](singlevm.md) template and helpers in utils directory.

## How to deploy
For detailed instructions on how to deploy as well as list of available properties, check this [README](./README.md)

## See also
[Other Fortigate deployments](./README.md)