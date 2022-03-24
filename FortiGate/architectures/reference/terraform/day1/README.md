# FortiGate Reference Architure for Google Cloud - Terraform
## Day 1 - Adding desired functionality

Day1 templates allow you to add and remove functionality from your existing FortiGate cluster. It is, and it should be treated as a merely example of possibilities and is not meant to be a complete production-ready set of modules for your own production deployment.

The example configuration will deploy the following:
1. Inbound inspection module
1. Outbound inspection module
1. VPC Peering to the workload VPC
1. Example workload server running nginx

## How to deploy
1. Prepare a VPC and a subnet to host your workload server. The CIDR range must not overlap with the IP space you used in day0 for the FortiGates. Make sure you deleted the default route to 0.0.0.0 and added a firewall rule allowing inbound connections to port 80.
1. Note down the selfLink of your subnet and provide it as `wrkld_demo_subnet` variable in terraform.tfvars file or when prompted by terraform
1. Initialize terraform by running `terraform init`
1. Create and verify a plan by running `terraform plan -out tf.plan`
1. Deploy by running `terraform apply tf.plan`
1. Wait up to a minute and test connection over http to the IP address visible in the outputs.

## How to clean up
Run `terraform destroy`
