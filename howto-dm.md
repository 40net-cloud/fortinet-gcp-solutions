# Getting started with Deployment Manager

Deployment Manager templates are build around **configurations**. Configurations can be provided directly (as static YAML files) or generated (using jinja templates or python scripts). As configurations and templates can be nested, the most common deployments will consist of a **configuration** file calling one or more templates with some properties. As this repository makes use mainly of jinja templates, the 3 different file types found here are:
- .yaml - static configuration files
- .jinja - templates, can use variables and control structures as well as take input parameters
- .jinja.schema - schema files define list of available parameters for a template with the same name, their format and default values. Do read schema file if you want to use a template

Rememeber - template files are compiled into a single yaml during deployment. Compiled YAML file is visible in deployment details page as "Expanded Config".

## Examples
deloyment-manager subdirectories located in each architecture directory contain several example configuration files. Except for [singlevm-no-template.yaml](FortiGate/architectures/100-single-vm/deployment-manager/singlevm-no-template.yaml), they can all be deployed without modifications as they will create a set of example VPC Networks and subnets (or any other required resources) before deploying FortiGate instances. Please be aware that deploying them will incur costs related to GCP infrastructure and, in some examples, to PAYG license fees.

Example configurations make use of a [sample-vpcs](FortiGate/modules-dm/utils-sample-vpcs.jinja) helper template for creating sample networks. This helper template is used solely for the clarity of examples' code. In your own production configurations you are expected to provide VPC Networks, subnets and CIDR ranges as input parameters.

## Building your own templates vs. using provided ones
You are encouraged to build your own templates or modify existing ones, however most of the templates in this repository were built with flexibility in mind making them a bit harder to debug, but easy to use. Before you modify the template do explore the schema file and examples - it's very likely your need is already covered by the provided jinja template with some additional optional properties.

## Basic FortiGate configuration
If you decide to build your own templates, an example of a configuration file for a single FortiGate VM instance is published in [singlevm-no-template.yaml](FortiGate/architectures/100-single-vm/deployment-manager/singlevm-no-template.yaml). You will notice some values are typed multiple times (e.g. region and zone), which makes it inconvenient to modify. This is exactly the reason for using templates, which can take information like a zone as a single input parameter (and derive region from it).

## Deploying a Deloyment Manager template or configuration
DM templates can be deployed using [`gcloud`](https://cloud.google.com/sdk) command-line tool available for local downloads and in your [cloud shell](https://cloud.google.com/shell/docs/using-cloud-shell). There is currently no option to deploy using a web console.

Templates (\*.jinja) can be referenced directly (and provided all parameters in the command line), e.g.:
```
gcloud deployment-manager deployments create DEPLOYMENT_NAME --template singlevm.jinja --properties=...
```
but it's much more practical (and recommended) to create a YAML [configuration file](https://cloud.google.com/deployment-manager/docs/configuration/create-basic-configuration) and use it instead:
```
gcloud deployment-manager deployments create DEPLOYMENT_NAME --config=config.yaml
```

As `gcloud` can fetch templates from remote servers for you - you do not need to clone whole repository to your disk. Simply create your *config* file locally and import templates from GitHub, like this:
```yaml
imports:
- path: https://raw.githubusercontent.com/fortinet/gcp-templates/master/FortiGate/modules-dm/fgcp-ha-ap-sdn.jinja
  name: fgcp-ha-ap-sdn.jinja
```

Remember to use link to the file itself (raw.githubusercontent.com) and not the link to GitHub page describing the file.
