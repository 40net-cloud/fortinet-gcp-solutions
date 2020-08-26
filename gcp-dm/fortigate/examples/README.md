# Examples: Fortigate Deployment Manager Configs

## How to use example configurations

All configurations and templates here are written for [GCP Deployment Manager](https://cloud.google.com/deployment-manager). DM templates can be deployed using [`gcloud`](https://cloud.google.com/sdk) command-line tool available for local downloads and in your [cloud shell](https://cloud.google.com/shell/docs/using-cloud-shell).

### To deploy an example:
1. Open the shell of your choice (e.g. Cloud Shell)
1. download the configuration file (no need to clone whole repository), e.g.:
`https://raw.githubusercontent.com/40net-cloud/fortinet-gcp-solutions/master/gcp-dm/fortigate/examples/ha-ap-elbilb.yaml`
For Cloud Shell you might want to use the Upload File feature available under multi-dot menu of the cloud shell
1. Edit configuration file to change properties or paths to license files
1. Preview the deployment to verify links and properties:
```
gcloud deployment-manager deployments create my-forti-template --config=ha-ap-elbilb.yaml --preview
```
At the end of preview you should see the list of resources to be deployed
1. Deploy
```
gcloud deployment-manager deployments update my-forti-template
```

### Using examples as base for your own deployments
Example configuration files are a good base for your own experiments. Check the .schema file related to the Jinja template referenced in the configuration to discover full list of available parameters and the default values. In most cases you should not need to edit jinja files. If you do - let us know and we'll be happy to parametrize your change in the next release of the templates.

## List of available configurations
### singlevm.yaml
This configuration uses [singlevm.jinja](../singlevm.jinja) template to deploy a single Fortigate instance with (default) PAYG licensing and 2 NICs. Private IP addresses will be calculated for the subnet CIDR ranges and assigned statically, External IP address will be created by the jinja template and assigned to port1.
To host the NICs, configuration file creates 2 VPC Networks with one subnet each before calling the template. Check the building block [info page](../singlevm.md) for more details.

### singlevm-custom-eip.yaml
This configuration uses [../singlevm.jinja](singlevm.jinja) template to deploy a single Fortigate instance with (default) PAYG licensing and 2 NICs. Private IP addresses will be assigned via DHCP to the instance (no static IP), and the port1 will be linked to the pre-existing External IP (properties.externalIP).
To host the NICs, configuration file creates 2 VPC Networks with one subnet each, as well as one External IP before calling the template. Check the building block [info page](../singlevm.md) for more details.

### ha-ap-sdn.yaml
This configuration uses [ha-ap.jinja](../ha-ap.jinja) template to deploy an Active-Passive HA cluster with 2 Fortigate members. It demonstrates ease of deployment of an HA cluster, where all configuration is automated and minimal set of properties needs to be passed in the config. Fortigates will be deployed with (default) PAYG licensing with 4 NICs (for external, internal, heartbeat and management networks). Heartbeat and management networks will be created by the template with the default CIDR subnets.
To host the NICs, configuration file creates 2 VPC Networks with one subnet each before calling the template. Check the building block [info page](../ha-ap.md) for more details.

### ha-ap-sdn-641.yaml
This configuration file deploys exactly the same architecture as ha-ap-sdn.yaml, but explicitly defines version to be 6.4.1.

### ha-ap-sdn_byol.yaml
This configuration uses [ha-ap.jinja](../ha-ap.jinja) template to deploy an Active-Passive HA cluster with 2 Fortigate members. It builds on the basic ha-ap-sdn.yaml by using BYOL licenses and defining address spaces for heartbeat and management networks.
NOTE: you have to provide 2 additional files containing Fortigate VM licenses in files license1.lic and license2.lic located in ../../secrets directory as indicated in the imports section. Feel free to modify the paths (but do not change names!) in import section to match your setup. 
To host the NICs, configuration file creates 2 VPC Networks with one subnet each before calling the template. Check the architecture [info page](../ha-ap.md) for more details.

### ha-ap-elbilb.yaml
This configuration uses [ha-ap-elbilb.jinja](../ha-ap-elbilb.jinja) template to deploy an Active-Passive HA cluster with 2 Fortigate members in a load balancer sandwich architecture. 2 External IPs labeled app1 and app2 will be created by the template. Heartbeat and management VPCs and subnets will be created by the template with the default addressing.
To host the NICs, configuration file creates 2 VPC Networks with one subnet each before calling the template. Check the architecture [info page](../ha-ap-elbilb.md) for more details.

### hub/config-byol-elbilb.yaml
This configuration uses [hub/fortigate-security-hub.jinja](../../hub/fortigate-security-hub.jinja) and [ha-ap-elbilb.jinja](../ha-ap-elbilb.jinja) to deploy a Security Hub protected with an Active-Passive HA cluster of Fortigates in LB sandwich. It's a full architecture suitable for most use-cases. Licensing is using BYOL scheme and you need to make sure you provide license1.lic nad license2.lic files. 4 hub VPC networks and subnets will be created by the template with the defaults defined in [hub/fortigate-security-hub.jinja.schema](../../hub/fortigate-security-hub.jinja.schema:hubNetworks). 3 spoke networks defined in configuration file (one, two, three) will be created and peered to hub internal VPC network. 2 External IPs (app1, app2) will be created as defined in the configuration file and redirected to FGT cluster.
NOTE: any architecture (singlevm, ha-ap, ha-ap-elbilb) can be used in the Security Hub. The selection of which one to use is done by pointing to the proper template in the configuration file. You MUST NOT change the "name" labels of imported templates as it's referenced later in the template.