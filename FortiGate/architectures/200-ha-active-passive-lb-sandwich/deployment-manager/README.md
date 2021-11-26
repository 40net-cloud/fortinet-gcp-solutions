# Deploying FortiGate A-P HA cluster in load balancer sandwich with Deployment Manager

## Templates

[fgcp-ha-ap-multilb.jinja](../../../modules-dm/fgcp-ha-ap-multilb.jinja) creates a cluster in load balancer sandwich with all required additional resources. I supports going beyond standard deployment and use more interfaces for a multi-nic E-W inspection (not a recommended architecture). Thanks to support for multiple ILBs, you can also deploy it between a VPC hosting GCP native connectivity services like Interconnect or Cloud VPN and your internal cloud network (see ha-ap-lb-sandwich-for-ic.yaml).

### Parameters
Most of the configuration is done in the properties.networks list. Each entry defines a multi-functional FGT network interface with the following options:
- networks[].externalIP - enables public IPs assigned to each of the firewall directly (e.g. for management)
- networks[].additionalExternalIPs[] - enables creation of External Load Balancer with one or more public IPs forwarded to firewall cluster. It will also add secondary IPs to FGT configuration as well as IP Pool.
- networks[].routes[] - enables creation of Internal Load Balancer and a custom route routed through it. It will also add a secondary IPs to FGT configuration and necessary routing entries for probe responses

For more details refer to examples and the [schema file](../../../modules-dm/fgcp-ha-ap-multilb.jinja.schema)

### Deployed Resources
- 2 FortiGate VM instances with 4 NICs each
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

*Note: these templates will trigger warnings by Deployment Manager due to use of unsupported feature (deployment manager actions) to add instances to unmanaged instance groups.*

## Examples

### ha-ap-lb-sandwich.yaml
Typical LB sandwich deployment for N-S inspection with a single public IP address and a default route from internal network.

![](https://lucid.app/publicSegments/view/03485829-8611-4788-a993-d32514d9a631/image.png)

### ha-ap-lb-sandwich-for-ic.yaml
This template adds a route on external side of the cluster. It can be used to route traffic from cloud-native connectivity like Cloud VPN or Interconnect via FGTs to internal side.

## Prerequisites and Requirements
You MUST create the external and protected VPC networks and subnets before using this template. External and protected subnets MUST be in the same region where VMs are deployed. You CAN create hasync and mgmt VPC Networks and subnets yourself or let the template create them for you.

All VPC Networks already created before deployment and provided to the template using `networks.*.vpc` and `networks.*.subnet` properties, SHOULD have first 2 IP addresses available for FortiGate use. Addresses are assigned statically and it's the responsibility of administrator to make sure they do not overlap.

## How to deploy
Deployment manager configs (YAML) can be deployed using the *gcloud* command line tool.

1. Open Cloud Shell
1. clone the git repository (it will also work if you download only a single yaml file and change the link in *imports* section to be an absolute URL of the file on GitHub)
1. deploy using
`gcloud deployment-manager deployments create my-fgt-poc --config ha-ap-lb-sandwich.yaml`

### See also:
- [Getting started with Deployment Manager](../../../../howto-dm.md)
