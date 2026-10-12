# Google Cloud NCC - inspection between VPC spokes

This is an example architecture which can be used for isnpecting traffic between NCC VPC Spokes. Traditional architecture based on peering is limited to 25 VPC peers and does not offer much flexibility on route filtering or transitiveness. NCC VPC Spokes are used by larger organizations seeking to go beyond the limitations of VPC Peering.

Visit [Google Cloud Architecture Center](https://docs.cloud.google.com/architecture/deploy-hub-spoke-vpc-network-topology#ncc) for more details.

The features and components used in this architecture are:
- [NCC VPC Spokes](https://github.com/40net-cloud/fortinet-gcp-solutions/blob/d6a79c72ec05f344293d93a0493a3f9aaa639551/FortiGate/architectures/ncc-inspection/ncc-hub-n-spoke.tf#L72C1-L116C2)
- [NCC Star topology](https://github.com/40net-cloud/fortinet-gcp-solutions/blob/d6a79c72ec05f344293d93a0493a3f9aaa639551/FortiGate/architectures/ncc-inspection/ncc-hub-n-spoke.tf#L1C1-L32C1)
- [NCC RA (Router Appliance) Spoke](https://github.com/40net-cloud/fortinet-gcp-solutions/blob/master/FortiGate/architectures/ncc-inspection/ncc-raspoke.tf)
- [NCC Route exchange](https://github.com/40net-cloud/fortinet-gcp-solutions/blob/d6a79c72ec05f344293d93a0493a3f9aaa639551/FortiGate/architectures/ncc-inspection/ncc-raspoke.tf#L24)
- [FortiGate HA (active-passive) cluster](https://github.com/40net-cloud/fortinet-gcp-solutions/blob/master/FortiGate/architectures/ncc-inspection/fgt.tf)

*Mind that FortiGate architecture and licensing can be freely replaced with any other pattern.*

## Routing setup

In this example FortiGate is [peered using BGP with NCC](https://github.com/40net-cloud/fortinet-gcp-solutions/blob/d6a79c72ec05f344293d93a0493a3f9aaa639551/FortiGate/architectures/ncc-inspection/ncc-raspoke.tf#L67C1-L95C2) to automatically learn prefixes of all VPC spoke subnets. You can replace the RA spoke with set of static routes on FortiGate internal port (especially if your VPC edge spokes addressing is well-organized and can be described by super networks).

Custom static routes in NCC edge spokes are needed to route traffic via FortiGates. As the dynamic routes advertised by FortiGate to NCC RA spoke are distributed only to the members of center group, you need a different way to route packets from edge spokes via FortiGate. You can achieve it by adding the following components:
1. internal passthrough network load balancer in RA spoke network, with FortiGate instances as backends (included as part of standard HA setup)
2. [custom static routes in each of edge spokes](https://github.com/40net-cloud/fortinet-gcp-solutions/blob/d6a79c72ec05f344293d93a0493a3f9aaa639551/FortiGate/architectures/ncc-inspection/fgt.tf#L91-L101) pointing to IP address of ILB from point 1
3. additional [center VPC spoke linked to FortiGate internal VPC](https://github.com/40net-cloud/fortinet-gcp-solutions/blob/d6a79c72ec05f344293d93a0493a3f9aaa639551/FortiGate/architectures/ncc-inspection/ncc-hub-n-spoke.tf#L62-L70) (the same VPC would be connected twice to NCC hub: once as RA spoke and once as center VPC spoke)

Mind that static routes in edge spoke VPCs are significantly different vs single route in hub VPC you would be using in peering-based architecture. The positive side is that routes in each individual edge spoke provide better granularity.

## How to deploy

1. Copy the files from this directory or clone the repository and change your current directory to this one
```
git clone https://github.com/40net-cloud/fortinet-gcp-solutions.git
cd FortiGate/architectures/ncc-inspection
```
2. Edit the `terraform.tfvars` file to match your needs. Change the prefix and labels so you can easily find the resources.
3. Set current GCP project and initialize Terraform:
```
export GOOGLE_PROJECT=`gcloud config get project`
terraform init
```
4. Deploy the template
```
terraform apply
```

To delete all resources once you're finished exploring simply run
```
terraform destroy
```