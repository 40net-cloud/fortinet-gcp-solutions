#FortiProxy in GCP

This example Deployment Manager template deploys a single FortiProxy instance into a new VPC.

## Hot to deploy

Before running the command below upload the .lic file to the location where you will e running deployment from as proxy1.lic, or remove references to that file in lines 3 and 11 of fpxdemo.yaml.
In a Cloud Shell session or in any other shell with Google Cloud CLI (gcloud) installed run the following command:

```
gcloud deployment-manager deployments create my-deployment --config fpxdemo.yaml
```

replacing `my-deployment` with your desired deployment name. After deployment completes wou will be shown the external address of your FortiProxy and the default password (set to instance ID).
