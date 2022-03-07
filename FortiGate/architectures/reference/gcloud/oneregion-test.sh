REGION=europe-west1
ZONE1=europe-west1-b
ZONE2=europe-west1-c
### Some resource names will be labeled with region or zone name. Let's use their
### shortened names:
REGION_LABEL=$(echo $REGION | tr -d '-' | sed 's/europe/eu/' | sed 's/australia/au/' | sed 's/northamerica/na/' | sed 's/southamerica/sa/' )
ZONE1_LABEL=$REGION_LABEL-${ZONE1: -1}
ZONE2_LABEL=$REGION_LABEL-${ZONE2: -1}

EIP_MGMT=$(gcloud compute addresses describe fgt-mgmt-eip-$ZONE1_LABEL --region=$REGION --format="get(address)")

echo "-----------------------------------------------------------"
echo "##  TEST: FGT HA clustering and licensing"
echo "##  Expected: primary and secondary reported with proper hostnames and non-empty serial numbers"
ssh admin@$EIP_MGMT "get sys ha status" | grep fgt-vm

echo "-----------------------------------------------------------"
echo "##  TEST: ELB health"
echo "##  Expected: one healthy, one unhealthy backend"
gcloud compute backend-services get-health fgtelb-bes-euwest1 --region=$REGION --format=json | jq ".[].status.healthStatus[] | {ipAddress,healthState}"

echo "-----------------------------------------------------------"
echo "##  TEST: ILB untrusted health"
echo "##  Expected: one healthy, one unhealthy backend"
gcloud compute backend-services get-health fgtilb-untrust-bes-euwest1 --region=$REGION --format=json | jq ".[].status.healthStatus[] | {ipAddress,healthState}"

echo "-----------------------------------------------------------"
echo "##  TEST: ILB trusted health"
echo "##  Expected: one healthy, one unhealthy backend"
gcloud compute backend-services get-health fgtilb-trust-bes-euwest1 --region=$REGION --format=json | jq ".[].status.healthStatus[] | {ipAddress,healthState}"

echo "-----------------------------------------------------------"
echo "##  TEST: peering routes for wrkld-dev"
echo "##  Expected: routes to workloads, onprem, PSA and default are listed and accepted"
gcloud compute networks peerings list-routes wrkld-peer-dev-to-hub-euwest1 --network=wrkld-dev-vpc-euwest1 --region=$REGION --direction=INCOMING

echo "-----------------------------------------------------------"
echo "##  TEST: peering routes for wrkld-nonprod"
echo "##  Expected: routes to workloads, onprem, PSA and default are listed and accepted"
gcloud compute networks peerings list-routes wrkld-peer-nonprod-to-hub-euwest1 --network=wrkld-nonprod-vpc-euwest1 --region=$REGION --direction=INCOMING

echo "-----------------------------------------------------------"
echo "##  TEST: peering routes for wrkld-prod"
echo "##  Expected: routes to workloads, onprem, PSA and default are listed and accepted"
gcloud compute networks peerings list-routes wrkld-peer-prod-to-hub-euwest1 --network=wrkld-prod-vpc-euwest1 --region=$REGION --direction=INCOMING
