# Deploying Peered Security Hub with Deployment Manager

*Note: Deployment Manager does not fully support creating VPC Peerings. It is possible only using actions, which are an unsupported feature and triggers warnings during deployment (it works though)*

Creating peerings is a realtively simple task and can be automated using Deployment Manager actions. `peerings.jinja` template published in this directory loops through the provided list of spoke VPCs, deletes the built-in default route and creates peerings with the appropriate route export/import settings.

Remember to add the names alongside URLs of hub and spokes if you're using it with references (jinja is able to automatically derive names from URLs only if it's given a literal, not a resource reference).

An example complete deployment of 2 spoke VPCs connected to a hub built with an HA A-P cluster in LB sandwich  is included in `hub.yaml` config.

### How to deploy
Deployment manager configs (YAML) can be deployed using the *gcloud* command line tool.

1. Open Cloud Shell
1. clone the git repository (it will also work if you download only a single yaml file and change the link in *imports* section to be an absolute URL of the file on GitHub)
1. deploy using
`gcloud deployment-manager deployments create my-fgt-poc --config hub.yaml`

### See also:
- [Getting started with Deployment Manager](../../../../howto-dm.md)
