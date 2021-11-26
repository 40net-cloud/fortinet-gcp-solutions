# Getting Started with Terraform
## Deploying with terraform
Terraform is a command-line tool you have to install. You can also use Cloud Shell, which already has the tool installed.
Terraform will read all files ending with `.tf` or `.tf.json` in the directory. Make sure you don't have any old files you don't want to deploy added to your working directory.

### Step 1
Make terraform install all required modules:
```
terraform init
```

### Step 2
Deploy the infrastructure:
```
terraform apply
```


## FortiGate images
You can either deploy one of the official images published by Fortinet or create your own image with disk image downloaded from [support.fortinet.com](https://support.fortinet.com). We recommend you use official images unless you need to deploy a custom image.

Fortinet publishes official images in *fortigcp-project-001* project. This is a special public project and every GCP user can list images available there using command

`gcloud compute images list --project fortigcp-project-001`

Official images for FortiGate have names starting with *fortinet-fgt-[VERSION]* (BYOL images) or *fortinet-fgtondemand-[VERSION]*. It is your responsibility to select the correct image if deploying using gcloud or templates (Deployment Manager templates in this repository automatically find image name based on version and licenses properties). Use filter and format options of gcloud command to get a clean list, eg.
`gcloud compute images list --project fortigcp-project-001 --filter="name ~ fortinet-fgtondemand AND status:READY" --format="get(selfLink)"`

will get you a list of image URLs for FortiGate PAYG, and

`FGT_IMG=$(gcloud compute images list --project fortigcp-project-001 --filter="name ~ fortinet-fgt- AND status:READY" --format="get(selfLink)" | sort -r | head -1)`

will save the URL of the newest BYOL image into FGT_IMG variable

## Authentication
In order to deploy terraform to GCP you must provide it the proper credentials. There are 2 methods of authenticating against GCP available in the Terraform GCP provider:
1. using temporary access token - this is the recommended way when deploying manually from a workstation
1. using a service account key - this is the method to use when terraform deployment is automated and not triggered manually by a human

### Temporary access token
The easiest way to deploy manually from a shell where Google Cloud SDN (gcloud) is installed is to use the same authentication method as gcloud itself.

Start by making sure you are logged in:
```
gcloud auth list
```
and authorize Google Auth Library:
```
gcloud auth application-default login
```
You will be taken to a web page to authorize ADC.
Afterwards Terraform will be able to automatically detect your login and act on your behalf.

Alternatively, you can export your temporary auth-token:
```
gcloud auth print-access-token
```
and add it to your Terraform template:
```
provider "google" {
  project = "{{YOUR GCP PROJECT}}"
  region  = "us-central1"
  zone    = "us-central1-c"
  access_token = "{{YOUR ACCESS TOKEN}}"
}
```
Keep in mind that access tokens are by design short-lived. You'll have to update the token in provider definition quite often.

### Service account key
In order to use this method you must first create a service account, generate and download its key and save it somewhere where terraform can access it.
Key can be pointed to by pointing an environment variable to it:
```
export GOOGLE_APPLICATION_CREDENTIALS={{path}}
```
or referenced explicitly in the provider definition:
```
provider "google" {
  project = "{{YOUR GCP PROJECT}}"
  region  = "us-central1"
  zone    = "us-central1-c"
  credentials = "{{PATH TO JSON KEY FILE}}"
}
```

## Cleaning up
In order to delete resources created by Terraform simply go to the directory where you deployed from and issue the following command:
```
terraform destroy
```

## References
* [Getting Started with the Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started)
