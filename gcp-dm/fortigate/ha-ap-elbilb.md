# Active-Passive HA Fortigate cluster in LB Sandwich
This template deploys 2 Fortigate instances in an HA cluster between two load balancers (load balancer sandwich pattern). LB Sandwich design enables use of multiple public IPs and provides faster, configurable failover times. HA multi-zone deployments provide 99.99% Compute Engine SLA.

## Diagram
![ELBILB Sandwich diagram](https://app.lucidchart.com/publicSegments/view/b1ee079a-3c64-4e75-acb7-a42e3b6f8982/image.png)

## Deployed Resources
- 2 Fortigate VM instances with 4 NICs each
- 4 VPC Networks (unless provided)
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