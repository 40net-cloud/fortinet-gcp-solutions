# Using Dynamic NICs with FortiGate

Dynamic NIC is a feature added to Google Compute around September 2025 and can be configured with any FortiGate version. At the time of writing of this article a feature request for automatic configuration of Dynamic NICs is pending implementation.

Advantages of using a Dynamic NIC instead of standard NICs:
- increased maximum limit of network interfaces (up to 16 for very large instance types)
- possibility to add/remove NICs without even rebooting VM
- shared NIC queues might increase performance in some cases

Disadvantages of Dynamic NICs in FortiGate:
- Dynamic NICs are technically subinterfaces and will be visible as such in management console

## Adding a Dynamic NIC to VM

*You can't add a Dynamic NIC using cloud web console. You have to use CLI (gcloud) or API. At the time of writing the feature is in preview and is not supported by Terraform.*

To add a Dynamic NIC to existing instance use `gcloud beta compute` command as below:

```
gcloud beta compute instances network-interfaces add INSTANCE_NAME --zone ZONE \
  --vlan VLANID \
  --parent-nic-name PARENT_NIC \
  --network VPC_NAME \
  --subnetwork SUBNET_NAME \
  --no-address
```

where,
- `VLANID` is your chosen VLAN tag used for communication between Google CLoud and VM
- `PARENT_NIC` is Google name of the parent NIC to be used as parent interface (mind different port naming between Google Cloud and FortiGate - eg. nic0 is port1)
- `VPC_NAME` and `SUBNET_NAME` - describe VPC and subnet you want to connect your NIC to

For more options to the command see the [documentation](https://cloud.google.com/sdk/gcloud/reference/beta/compute/instances/network-interfaces/add).

## Manually configuring Dynamic NIC in FortiGate

*NOTE: Dynamic NICs can be configured in FortiGate only using CLI or API. Option is not available in web console.*

To configure sub-interface linked to Google Dynamic NIC you need to first find out its parameters:
- IP address
- MAC address
- VLAN ID

VLAN ID is the number you defined in gcloud command above.

IP address can be either configured statically in the gcloud command above or assigned as ephemeral internal address, which is visible in VM instance details in web console or using `gcloud compute instances describe INSTANCE_NAME --zone ZONE`.

MAC address can be obtained from metadata server. It seems it's directly mapped from the internal IP address by prepending `42:01:` to it (eg. for IP address **10.0.2.2** the MAC address would be **42:01:0a:00:02:02**), but it's not an officially documented pattern and it can change any time.

To reliably obtain assigned MAC address:
1. connect to FortiGate CLI
2. issue the following command: `execute telnet 169.254.169.254 80`
3. query the metadata server for the mac address using **PARENT_NIC_INDEX** (eg. **0** for **nic0**/**port1**) and **VLANID** to build the URL path:
        GET /computeMetadata/v1/instance/vlan-network-interfaces/PARENT_NIC_INDEX/VLANID/mac HTTP/1.0
        Metadata-Flavor: Google


4. add the interface to FortiGate configuration. You can name your interface any way you want (eg. *new_nic*), the standard naming would be to use port and vlan id (eg. port1.200):
        config sys interface
          edit new_nic
            set vdom root
            set type emac-vlan
            set vlanid VLANID
            set interface PARENT_PORT
            set macaddr MAC_ADDRESS
            set ip IP_ADDRESS 255.255.255.255
          next
        end
5. remember to add any subnets to static routing as you would normally do
        config router static
          edit 0
            set dst SUBNET_CIDR
            set gateway SUBNET_GW
            set device new_nic
          next
        end


### References

- ask your Fortinet SE for status of NFR 1218560 for automated Dynamic NIC management
- [Adding Dynamic NICs in standard Linux instances](https://cloud.google.com/vpc/docs/add-dynamic-nics)
- [Maximum number of interfaces](https://cloud.google.com/vpc/docs/multiple-interfaces-concepts#max-interfaces)