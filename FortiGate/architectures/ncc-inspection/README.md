# Google Cloud NCC - inspection between VPC spokes
## draft


This is an example architecture which can be used for isnpecting traffic between NCC VPC Spokes. Traditional architecture based on peering is limited to 25 VPC peers and does not offer much flexibility on route filtering or transitiveness. NCC VPC Spokes are used by larger organizations seeking to go beyond the limitations of VPC Peering.

The features and components used in this architecture are:
- NCC VPC Spokes
- NCC Star topology
- NCC RA (Router Appliance) Spoke
- NCC Route exchange
- FortiGate HA (active-passive) cluster

*Mind that FortiGate architecture and licensing can be freely replaced with any other pattern.*

## Routing setup

In this example FortiGate is peered using BGP with NCC to automatically learn prefixes of all VPC spoke subnets. You can replace the RA spoke with set of static routes on FortiGate internal port (especially if your VPC edge spokes addressing is well-organized and can be described by super networks).

Custom static routes in NCC edge spokes. As the dynamic routes advertised by FortiGate to NCC RA spoke are distributed only to the members of center group, you need a different way to route packets from edge spokes via FortiGate. You can achieve it by adding the following components:
1. internal passthrough network load balancer in RA spoke network, with FortiGate instances as backends (included as part of standard HA setup)
2. custom static routes in each of edge spokes pointing to IP address of ILB from point 1
3. additional center VPC spoke linked to FortiGate internal VPC (the same VPC would be connected twice to NCC hub: once as RA spoke and once as center VPC spoke)

Mind that static routes in edge spoke VPCs are significantly different vs single route in hub VPC you would be using in peering-based architecture. The positive side is that routes in each individual edge spoke provide better granularity.