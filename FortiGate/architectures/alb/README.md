# FortiGate HA cluster deployed behind a global ALB

FortiGate cluster in Google Cloud is usually deployed behind a external pass-through network load balancer (NLB). In some cases though it might be desireable to add an Application Load Balancer instead of NLB to leverage Cloud Armor or global nature of ALB. This repo contains a demo terraform template to deploy such environment.

**NOTE: this template uses PAYG licenses for FortiGates by default. If you wish to use your own BYOL licenses add them to module parameters in main.tf or add FortiFlex tokens to flex variable**

**NOTE 2: this type of setup is HTTP-centric. Consider using FortiWeb instead FortiGate to elevate protection for your web applications and APIs.**

## Architecture

FortiGates in this demo are deployed in a standard active-passive HA cluster between external and internal pass-through network load balancers. On the internal part you will find a single Ubuntu VM instance hosting an nginx web server. On external side this template adds an Application Load Balancer on a dedicated public IP address with HTTP protocol redirected to HTTPS and a simple security policy attached.

This module has no prerequisites except for enabled Compute API. It will create all the needed resources including VPC Networks, VMs, load balancers, etc. Make sure your project quota allows to create additional 3 VPCs (default quota is 5). 

![Architecture diagram](https://lucid.app/publicSegments/view/d5e69875-38c7-4eff-8011-05bcc1a2af36/image.png)

### Traffic flow

1. HTTP(S) request from Internet is handled by ALB and passed to the active FortiGate instance with SNAT
2. FortiGate DNATs connection to the web server VM. SNAT is also applied to ensure the return packet will be sent back to FortiGate instance and not directly to ALB address
3. Return packet is sent to FortiGate instance which originally processed the packet initiating the connection (mind that because of SNAT, the ILB and custom route in internal VPC are ignored)
4. FortiGate forwards the return packet back to ALB

### FortiGate configuration

HTTP(S) load balancer performs both source and destination NATs, which means original client IP address will not be visible in IP layer and the destination will be set to FortiGate VM private IP address. The consequences of this NAT for the configuration are as follows:

1. Even if ALB has multiple frontends, they are indistinguishable once the traffic reaches FortiGates. Therefore, FGT policy cannot be used to distribute traffic based on IP addresses.
2. In case the traffic needs to be directed to multiple targets based on HTTP parameters (hostname, URL path, etc) you should deploy an internal HTTP laod balancer between FortiGates and the workloads (or use FortiWeb instead).
3. Connections MUST be SNATed on FortiGate to make sure the return packet flow will be sent through the FGT VMs. Without SNAT the return flow will be sent directly to ALB.

This example code automatically configures firewall policies to forward traffic to a demo web server.

## How to use
### Deploy

The easiest way to deploy terraform to GCP is using Cloud Shell:

1. Open Cloud Shell from Google Cloud console
2. Clone this repository: `git clone https://github.com/bartekmo/ftnt-demo-gcp-alb.git`
3. Change to repo directory: `cd ftnt-demo-gcp-alb`
4. Initialize terraform: `terraform init`
5. Deploy: `terraform apply`
6. After deployment completes terraform will output information about connectivity similar to this:

```
alb_address = "34.128.164.174"
fgt_management_address = "34.65.215.143"
fgt_password = "398635541547203305"
```

### Play

Open your web browser and go to **http://*[alb_address]*** (replacing *[alb_address]* with the value from outputs, obviously). You should be redirected to HTTPS connection (you will notice because your web browser will warn about invalid certificate) and show the default nginx web page.

Open [Google Cloud console](http://console.cloud.google.com) to explore the settings of NLB and ALB. Note that they use two different backends (regional and global, respectively).

Use FGT management address and password from terraform outputs to connect to FortiGate web console (on standard HTTPS port). All connections should be visible in **Log&Report** > **Forward Traffic**. Explore the firewall policy in **Policy&Objects** > **Firewall Policy** and DNAT settings in **Policy&Objects** > **Virtual IPs**.

### Clean up

After you're done remember to run `terraform destroy` to delete all resources used in this demo.

## Troubleshooting

- if you cannot reach the web server, restart it. In some cases wb server might not provision properly
- to verify the connections on the FortiGate use the management address and initial password from outputs to connect to primary FortiGate management console or CLI
- this template uses a factory branch of FortiGate HA module. In some time this branch will be likely merged to main and I might forget to update this repo. If terraform complains it cannot find the module to import, try removing "?ref=v1.1" from module's source parameter in main.tf file