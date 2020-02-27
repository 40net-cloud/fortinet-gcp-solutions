Security Hub VPC Network with Fortigate P-A HA Pair
GCP Deployment Manager template

Deploy
gcloud deployment-manager deployments create [deployment name] --config config.yaml

Post-deployment steps
1. Enable export custom routes on all peerings from Hub VPC
2. enable import custom routes on all peerings from spoke VPCs