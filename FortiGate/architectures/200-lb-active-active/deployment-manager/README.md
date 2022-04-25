# Deploying Active-Active group with Deployment Manager

fgsp-aa-multilb.jinja template currently supports only 2 active group members and 3 network interfaces (port3 reserved for FGSP communication).

`config-aa.yaml` example file demonstrates how to deploy the solution consisting of:
- 2 FortiGate instances preconfigured with FGSP
- 2 external IP addresses (addr1 and addr2)
- set of resources for external load balancer
- set of resources for internal load balancer
- default route in internal VPC pointing to ILB

## How to deploy
Deployment manager configs (YAML) can be deployed using the *gcloud* command line tool.

1. Open Cloud Shell
1. clone the git repository (it will also work if you download only a single yaml file and change the link in *imports* section to be an absolute URL of the file on GitHub)
1. deploy using
`gcloud deployment-manager deployments create my-fgt-poc --config ha-ap-lb-sandwich.yaml`

### See also:
- [Getting started with Deployment Manager](../../../../howto-dm.md)
