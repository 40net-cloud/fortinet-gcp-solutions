#### FortiGate Reference Architecture for GCP
# FortiGate HA Cluster Base

Regardless of the placing of your FortiGate VM instances in GCP infrastructure some parts of the architecture are common for all use-cases. This article describes the recommended design for the cluster, prerequisites and some best practices.

## Prerequisites
Before deploying FortiGate VMs you need to prepare 2 types of resources:
1. Service account
1. VPC Networks and subnets

**Service account** is a type of GCP IAM account dedicated for use by VMs and services. When deploying any VM in GCP you can assign it a service account, which the VM will be using to connect to GCP APIs. VM can download temporary tokens for its service account from the private metadata service (169.254.169.254) thus removing the necessity to manually handle service account keys (generating keys for service account should be always your last option).

FortiGate uses service account during boot-up to verify it actually is running in Google Cloud, as well as in Fabric Connector (a.k.a. SDN Connector) so it can use of metadata instead of IP addresses in firewall address objects. By default all new VMs are assigned the built-in *Default Compute Engine Service Account*, which by default has project Owner role. Following the minimum privilege principle you SHOULD create a dedicated role and account for your FortiGate appliances. Check [here](../docs/sdn_privileges.md) how to create them and what are the required privileges your FortiGates do need.

**VPC Networks and subnets** - as FortiGates will be deployed as multi-NIC VMs and in Google Cloud each NIC of a VM instance must be connected to a separate VPC Network, you MUST create 4 (four) separate VPC Networks and subnets. Subnets MUST be in the same region as the FortiGates and cannot have overlapping IP ranges. The templates allocate static IP addresses automatically so there's no need for the subnets to be empty.

## FortiGate Clustering Protocol (FGCP) in public cloud
[FGCP](https://docs.fortinet.com/document/fortigate/7.0.3/administration-guide/62403/fgcp) is a proprietary protocol used to create high-availability clusters in both hardware and virtual FortiGate deployments. Due to the way cloud networks work, you cannot take full advantage of the protocol capabilities and you have to use its unicast version limiting the functionality to active-passive cluster of two instances.

FGCP will provide automatic synchronization of connection tables as well as synchronization of configuration from primary to secondary (all configuration changes need to be applied to the primary instance). It's recommended to use priority option to assign statically the primary and secondary roles in the cluster.

## VM instances and networks
FortiGates are deployed as 2 VM instances in 2 different availability zones of the same region, with 4 NICs each:
- port1 (nic0) - external (untrusted) traffic
- port2 (nic1) - internal (trusted) traffic
- port3 (nic2) - heartbeat and FGCP configuration sync
- port4 (nic3) - dedicated management interface

*Note that more internal NICs might be needed if the number of security zones (VPCs) in east-west segmentation use-case exceeds maximum size of a peering group (25).*

*Note2: starting from firmware 7.0 you can use the same NIC for FGCP heartbeat and management*

Machine type depends on your use-case, but to accommodate for 4 NICs it must have 4 vCPUs or more. We recommend starting with N2-standard-4 instance for firewalling and threat inspection use-cases and with C2-standard-4 if the main use-case is VPN-related.

You should create and attach a logdisk to each instance to store log data.

FortiGates shall be configured in a unicast FGCP active-passive cluster with heartbeat over port3 and dedicated management on port4. Port4 can be optionally linked to an external IP unless the private IP addresses of the interfaces are available in another way (e.g. via VLAN attachment). No other NICs need public IP addresses. Port3 needs a static private IP address as it's part of the configuration of the peer instance in the cluster. Other NICs can be configured with static IP addresses for consistency.

Outbound connections from port1 to Google Compute API and FortiGuard services must be made available, preferably using Cloud NAT or using public IPs attached directly to port1 of each VM.

## Load Balancers and traffic flows
Cloud infrastructure directs traffic flows to the active FortiGate instance using load balancers. In this case load balancers will not really balance the connections but simply direct them to the single active (healthy) instance and not to the passive (unhealthy) one. Both Internal and Extenral Load Balancers in GCP can use a Backend Service as the target. You will have to create a separate regional Backend Service resource for each interface receiving production traffic (port1 and port2, but not port3 and port4) as well as a Forwarding Rule to bind a load balancer frontend IP address with the backend service. You can re-use the same Unmanaged Instance Groups for all Backend Services. Mind that in case of processing both the traffic from public Internet as well as traffic from Interconnect you will have to create both external and internal load balancer for port1. When creating load balancers using web console their internal components (Backend Service, Forwarding Rule) might be not explicitly visible.

Internal Load Balancers will be [used as next hop by custom routes](https://cloud.google.com/load-balancing/docs/internal/ilb-next-hop-overview) and it's enough to use a rule for any port of either TCP or UDP protocol. Custom route will automatically enable routing of all TCP/UDP/ICMP traffic.

External Load Balancer does not support routing, so the connections to its public IP addresses will have to be terminated or translated on the active FortiGate. It's recommended to use the new L3_DEFAULT protocol for ELB.

## Health Checks and HA Failover
Load Balancers detect active instance using [health checks](https://cloud.google.com/load-balancing/docs/health-check-concepts). There are 3 possibilities to handle the health probes:

1. [Responding to probes](https://docs.fortinet.com/document/fortigate/7.0.1/cli-reference/123620/config-system-probe-response) directly on the FortiGate using secondary IP addresses of the interface - this is the easiest solution recommended in most cases (requires least configuration on FortiGate), but it's limited by the maximum number of secondary addresses
2. Creating additional loopback interface and redirecting probes to it using VIPs - this solution is recommended if you create FortiGate configuration using terraform as (unlike secondary IPs) the VIPs and firewall policies can be easily created and destroyed. It's also recommended to use this approach if you have many public IP addresses.
3. Forwarding probes to the backend server - this solution is not recommended as a failover of a single backend service will attempt to fail over whole firewall cluster, which in many cases will not match the FGCP status.

[Connection Tracking](https://cloud.google.com/load-balancing/docs/internal#connection-persistence) feature of GCP load balancers (in preview at the time of writing) allows graceful failover of existing connections. Use it if your company policy allows using Google Compute Beta API.
