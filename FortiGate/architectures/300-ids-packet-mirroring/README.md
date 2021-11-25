# Fortinet IDS for Google Cloud
FortiGate virtual appliances are capable of detecting and blocking threats using the FortiLabs-powered IDS/IPS system as well as the built-in antivirus engine. While it is recommended to deploy FortiGates inline, so the threats can be blocked as soon as they are detected, it is not possible to do so for the network traffic inside a Google Cloud VPC Network. In this case, one can utilize GCP Packet Mirroring feature together with FortiGate one-arm-sniffer mode to detect malicious or infected traffic and alert the administrators. For multiple sensors it's best to use FortiAnalyzer as the correlation and aggregation engine providing single pane of glass insights into the traffic patterns as well as detected threats or compromised VMs.

This template fully automates the deployment and configuration of a mesh of FortiGate IDS sensors connected to a FortiAnalyzer.

## Design
![](https://lucid.app/publicSegments/view/5305e424-be22-4faa-9e62-d4b133d15a97/image.png)

## Prerequisites
Before deploying this template have your FortiAnalyzer deployed. You will need to provide its serial number and the IP address where FortiGate sensors can reach it.

## Configuration
To use this Deployment Manager template you need to define your own configuration (YAML) file. A sample configuration is provided, but you have to modify it to point to your own resources. Unlike most of example configs published in this repository, this one will NOT work without customization. See below for the required properties:

### sensors section

sensors.fortiAnalyzer.address - IP address at which FortiAnalyzer is reacheable
sensors.fortiAnalyzer.serial - serial number of the FortiAnalyzer

### mirroringPolicies list

mirroringPolicies[].region - region covered by mirroring policy
mirroringPolicies[].target.vpcNetwork - URL of the VPC Network to enable mirroring for


## Scaling the sensor instance pool
As mirrored traffic in Google Cloud cannot be sent outside the region, a pool (Managed Instance Group) of FortiGate instances must be created in each region defined in the mirroring policies. The sizes of these groups are static, governed by regional instance group managers (compute-v1:regionInstanceGroupManagers) and defined by the properties in the configuration file. By default each region is assigned 2 instances. This global default can be changed by using sensors.defaultSensorCount property of the template. If changing target group sizes to equal value in each region is not what you need, you can affect group sizes in individual regions by assigning a sensorCount property in individual mirroring policies. All sensorCount values defined in policies referencing the same region will be added and the sum will be applied as the target size of the shared regional IDS sensors pool.

Note: sensorCount property must be greater than 0 or not defined.
