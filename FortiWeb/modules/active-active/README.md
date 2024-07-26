# FortiWeb active-active cluster

** NOTE: this module is not fully functional, check Mantis #1056936 before use.**

This is an alternative terraform module to the one found [here](gcp/terraform/Active-Active).

This module deploys an active-active cluster of 2 FortiWebs in Google Cloud. It allows the user to choose between firmware versions and licensing, as well as between the type of the external load balancer.

## Supported Load Balancers

### External pass-through network load balancer

By setting variable `frontend_type` to `nlb` this module will deploy an external pass-through network load balancer with a single external IP and both ports 80 and 443 forwarded to the FortiWebs. This type of load balancer does not perform any network translation or SSL offloading, so the client IP address is visible in the IP header and the decryption is handled by the FortiWebs.

This type of load balancer also allows to easily add more public IP addresses later on, which can be used to dispatch traffic using FortiWeb Virtual IPs.

### External global HTTP load balancer

By setting variable `frontend_type` to `http` this module will deploy a global HTTP load balancer with HTTP forwarding rule. It is not advised to use this configuration in production due to lack of transport encryption, but it may be useful for demmonstration purposes.

### External global HTTPS load balancer

By setting variable `frontend_type` to `https` this module will deploy a global HTTP load balancer with HTTP redirection to HTTPS and a HTTPS forwarding rule. All HTTPS decryption will be handled by the load balancer and traffic will be forwarded to FortiWeb cluster using plain-text HTTP. Mind that this type of load balancer uses network translation for both source and destination IP addresses. Original client source IP address can be obtained from the HTTP headers. All traffic will be sent to FortiWebs' individual private IP addresses on port1, so it is not possible to distinguish multiple destinations using virtual IPs.

## VM instance source images

Public cloud instances of FortiWeb can be created using base images published by Fortinet in public catalog or using custom images uploaded by users. It is recommended to use the public images unless the particular version you are deploying is not available. Images are published in two versions: "payg" are automatically licensed using Google Cloud marketplace and the license fee will be added to the cloud billing for the time the VM is running; "byol" require adding a license obtained from Fortinet channel partner or a FortiFlex token. It is not possible to use PAYG image with license obtained outside of the cloud marketplace, and it is not possible to convert a VM instance between PAYG and BYOL licensing (this operation requires re-deploying of the VM).

The easiest way to select the image is to provide the desired firmware version in `image.version` variable, eg.:

```
image = {
    version = "7.4.4"
}
```

Skipping the last digit and provide only the major version (eg. "7.4") will cause the module to select the newest image from a given branch. Skipping version entirely will cause the module to select the newest available FortiWeb image.

Licensing defaults to "PAYG" but can be enforced using `image.license` variable, eg.:

```
image = {
    license = "byol"
}
```