REGION=europe-west1
ZONE1=europe-west1-b
ZONE2=europe-west1-c
REGION_LABEL=$(echo $REGION | tr -d '-' | sed 's/europe/eu/' | sed 's/australia/au/' | sed 's/northamerica/na/' | sed 's/southamerica/sa/' )
ZONE1_LABEL=$REGION_LABEL-${ZONE1: -1}
ZONE2_LABEL=$REGION_LABEL-${ZONE2: -1}
GCP_PROJECT_ID=$(gcloud config get-value project)

gcloud compute routes delete rt-untrust-to-psa-$REGION_LABEL-via-fgt -q
gcloud beta sql instances delete wrkld-priv-sql-$REGION_LABEL -q
gcloud compute addresses delete wrkld-trust-psa-range --global -q
gcloud beta compute forwarding-rules delete fgtelb-serv1-fwd-$REGION_LABEL-l3 --region=$REGION -q
gcloud beta compute backend-services delete fgtelb-bes-$REGION_LABEL --region=$REGION -q
gcloud compute addresses delete fgtelb-serv1-eip-$REGION_LABEL --region=$REGION -q
gcloud compute routes delete rt-trust-to-wrkld-$REGION_LABEL-via-fgt -q
gcloud compute routes delete rt-untrust-to-wrkld-$REGION_LABEL-via-fgt -q
gcloud compute networks peerings delete wrkld-peer-hub-to-dev-$REGION_LABEL --network=trust-vpc-$REGION_LABEL -q
gcloud compute networks peerings delete wrkld-peer-dev-to-hub-$REGION_LABEL --network=wrkld-dev-vpc-$REGION_LABEL -q
gcloud compute networks peerings delete wrkld-peer-nonprod-to-hub-$REGION_LABEL --network=wrkld-nonprod-vpc-$REGION_LABEL -q
gcloud compute networks peerings delete wrkld-peer-hub-to-nonprod-$REGION_LABEL --network=trust-vpc-$REGION_LABEL -q
gcloud compute networks peerings delete wrkld-peer-prod-to-hub-$REGION_LABEL --network=wrkld-prod-vpc-$REGION_LABEL -q
gcloud compute networks peerings delete wrkld-peer-hub-to-prod-$REGION_LABEL --network=trust-vpc-$REGION_LABEL -q
gcloud compute networks subnets delete wrkld-dev-sb-$REGION_LABEL --region=$REGION -q
gcloud compute networks subnets delete wrkld-nonprod-sb-$REGION_LABEL --region=$REGION -q
gcloud compute networks subnets delete wrkld-prod-sb-$REGION_LABEL --region=$REGION -q
gcloud compute networks delete wrkld-dev-vpc-$REGION_LABEL -q
gcloud compute networks delete wrkld-nonprod-vpc-$REGION_LABEL -q
gcloud compute networks delete wrkld-prod-vpc-$REGION_LABEL -q
gcloud compute routes delete rt-trust-$REGION_LABEL-to-onprem-via-fgt -q
gcloud compute routes delete rt-trust-$REGION_LABEL-default-via-fgt -q
gcloud compute forwarding-rules delete fgtilb-untrust-fwd-$REGION_LABEL-tcp --region=$REGION -q
gcloud compute backend-services delete fgtilb-untrust-bes-$REGION_LABEL --region=$REGION -q
gcloud compute forwarding-rules delete fgtilb-trust-fwd-$REGION_LABEL-tcp --region=$REGION -q
gcloud compute backend-services delete fgtilb-trust-bes-$REGION_LABEL --region=$REGION -q
gcloud compute health-checks delete fgt-hcheck-tcp8008 --region=$REGION -q
gcloud compute instance-groups unmanaged delete fgt-umig-$ZONE2_LABEL --zone=$ZONE2 -q
gcloud compute instance-groups unmanaged delete fgt-umig-$ZONE1_LABEL --zone=$ZONE1 -q
gcloud compute instances delete fgt-vm-$ZONE2_LABEL --zone=$ZONE2 -q
gcloud compute instances delete fgt-vm-$ZONE1_LABEL --zone=$ZONE1 -q
gcloud iam service-accounts delete fortigatesdn-ro@$GCP_PROJECT_ID.iam.gserviceaccount.com -q
## deleting a role is as messy as deleting a project. don't do it 
#gcloud iam roles delete FortigateSdnReader --project=$GCP_PROJECT_ID -q
gcloud compute addresses delete fgt-ip-hasync-$ZONE2_LABEL --region=$REGION -q
gcloud compute addresses delete fgt-ip-hasync-$ZONE1_LABEL --region=$REGION -q
gcloud compute addresses delete fgtilb-ip-untrust-$REGION_LABEL --region=$REGION -q
gcloud compute addresses delete fgt-ip-untrust-$ZONE2_LABEL --region=$REGION -q
gcloud compute addresses delete fgt-ip-untrust-$ZONE1_LABEL --region=$REGION -q
gcloud compute addresses delete fgtilb-ip-trust-$REGION_LABEL --region=$REGION -q
gcloud compute addresses delete fgt-ip-trust-$ZONE2_LABEL --region=$REGION -q
gcloud compute addresses delete fgt-ip-trust-$ZONE1_LABEL --region=$REGION -q
gcloud compute addresses delete fgt-mgmt-eip-$ZONE2_LABEL --region=$REGION -q
gcloud compute addresses delete fgt-mgmt-eip-$ZONE1_LABEL --region=$REGION -q
gcloud compute routers delete untrust-nat-cr-$REGION_LABEL --region=$REGION -q
gcloud compute firewall-rules delete fgt-mgmt-fw-allow-admin -q
gcloud compute firewall-rules delete fgt-hasync-fw-allowall -q
gcloud compute firewall-rules delete trust-to-fgt-fw-allowall -q
gcloud compute firewall-rules delete untrust-to-fgt-fw-allowall -q
gcloud compute networks subnets delete fgt-mgmt-sb-$REGION_LABEL --region=$REGION -q
gcloud compute networks subnets delete fgt-hasync-sb-$REGION_LABEL --region=$REGION -q
gcloud compute networks subnets delete trust-sb-$REGION_LABEL --region=$REGION -q
gcloud compute networks subnets delete untrust-sb-$REGION_LABEL --region=$REGION -q
gcloud compute networks delete fgt-mgmt-vpc -q
gcloud compute networks delete fgt-hasync-vpc -q
gcloud compute networks delete trust-vpc-$REGION_LABEL -q
gcloud compute networks delete untrust-vpc-global -q
