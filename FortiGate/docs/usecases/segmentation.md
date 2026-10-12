### FortiGate use-cases in Google Cloud
# Segmentation

Segmentation us-case is about inspecting traffic between workloads or services located in the public cloud. It enhances your security posture vs standard "allow/deny" firewalling by adding application awareness, TLS inspection and IPS to prevent lateral movement between compromised and attacked resources.

Segmentation can be achieved by inspecting traffic between groups of resources connected to different VPCs (which is more common) and between workloads in the same VPC/subnet. Mind that inspecting all traffic between eery individual VM in a subnet might require a high-performance FortiGate cluster (either active-active or autoscaling).

## Architectures

### Peering-based hub and spoke

This is a traditional and most commonly deployment scenario. VPC Peering is leveraged to provide connectivity between VPCs at high speed and low latency. VPC Peering does not introduce additional costs (data transfer costs might still apply for traffic leaving availability zone).

**Pros:**
- high speed, low latency
- easy to set up
- single custom route propagated automatically to all spokes

**Cons:**
- limited to 25 spokes
- lacking transitivness for PSC endpoints in spokes (shared PSC can be easily added to hub and inspected by FGT)
- lacking flexibility in routing

#### How to set it up

1. Connect all spoke VPCs to a hub VPC using VPC peering. For each peering enable "Import custom routes" on the spoke side and "Export custom routes" on hub side.
2. Deploy FortiGate(s) connecting hub VPC to internal port. Any FortiGate deployment will work in this setup (from single instance, to autoscaling). Most common choice is an active-passive cluster in a load balancer sandwich - internal port in this case would be port2. The remaining ports would be connected to other VPCs not being part of the segmentation use-case.
3. Create a custom static route in hub VPC with next hop being internal network pass-through load balancer of FortiGate cluster.
4. Make sure your FortiGate(s) have route to all spoke VPC subnets via internal port.
5. Verify the custom route go propagated to all spokes (spokes will show it with next hop being the VPC peering)

For more details and an example Terraform code go [here](../../architectures/300-peered-security-hub/)

### NCC-based hub and spoke

NCC (Network Connectivity Center) star topology is a modern version of hub and spoke. By leveraging

**Pros:**
- high speed, low latency
- flexibility in setting up routing with include/exclude filters
- supports PSC endpoints in spokes
- higher supported number of spokes vs. peering-based architecture

**Cons:**
- additional cost for NCC spokes
- more complicated setup
- number of spokes limited to 250

#### How to set it up

1. Create an NCC hub with star topology
2. Create NCC spoke groups (`center` and `edge`)
3. Add hub VPC to the center group as a VPC spoke
4. Add spoke VPCs to the edge group as VPC spokes
5. Deploy FortiGate cluster with internal ports connected to the spoke hub. Mind that this architecture requires and internal load balancer - you have to add it even if you're deploying a single FortiGate instance or if you decided to leverage SDN connector for HA failover. Most common choice is an active-passive cluster in a load balancer sandwich - internal port in this case would be port2. The remaining ports would be connected to other VPCs not being part of the segmentation use-case.
6. In each spoke VPC create a custom static route pointing to **IP address** of internal load balancer in hub VPC.
7. Make sure your FortiGate(s) have route to all spoke VPC subnets via internal port. Routes to spoek VPCs can be learned automatically if you additionally create an NCC RA spoke connected to hub VPC and to your FortiGate(s).

### VPN-based hub and spoke

VPC-to-VPC VPN is a rarely used option for building hub-and-spoke architecture due to low throughput and high cost. Reach out to your local Fortinet public cloud specialist for advisory on configuration.

### Policy-based routing

PBR (policy-based routing) is an alternative routing engine which allows to override subnet routes within a VPC. In practice, it can be used to route traffic between resources in the same VPC via a FortiGate (or FortiGate cluster) offering extreme granularity in traffic inspection.

### NSI in-band