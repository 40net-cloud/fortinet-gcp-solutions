cat oneregion.sh | egrep -i '^(REGION|ZONE)' > oneregion-destroy.sh
cat oneregion.sh | grep 'gcloud.*create' | grep -v "compute disks" | grep -v "compute routers nats" | tail -r | sed 's/create/delete/g' | sed 's/\\/-q/g' >> oneregion-destroy.sh
