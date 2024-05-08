set -e

#!/bin/bash

######### Expected Inputs ############

## $1 = Action. Either "add" or "rm"
## $2 = Cluster Name
## $3 = LOAD_BALANCER_IP "provided" or "fetched"
## $4 = RESOURCE_GROUP 
## $5 = VNET_NAME      
## $6 = SUBNET_NAME    
######################################

if [ "$#" -ne 2 ]; then
  echo "ERROR: Incorrect number of arguments, received $#, but 2 are required"
  echo "Usage:"
  echo "$0 ACTION CLUSTER_NAME"
  for param in "$@"
  do
   echo "Received: " $param
  done
  exit 1
fi

ACTION=$1
CLUSTER_NAME=$2
# LOAD_BALANCER_IP=$3
# RESOURCE_GROUP=$4
# VNET_NAME=$5
# SUBNET_NAME=$6

# if [ -z "$LOAD_BALANCER_IP" ]; then
#   echo "Get an IP from the subnet"
#   LOAD_BALANCER_IP=$(az network vnet subnet list-available-ips --resource-group $RESOURCE_GROUP --vnet-name $VNET_NAME --name $SUBNET_NAME --query [0])
#   echo "Assigned IP: $LOAD_BALANCER_IP"
# fi

# export LOAD_BALANCER_IP

echo "Paremeters in use:"
echo "ACTION: $ACTION"
echo "CLUSTER_NAME: $CLUSTER_NAME"

echo "current working directory:"
pwd
cd ../../../../
echo "working directory:"
pwd
echo "Checking for cluster yaml file..."
if pwd | grep -q managed-environment; then
  echo "In managed-environment repo"

if ls | grep -q $CLUSTER_NAME.yaml; then

  BRANCH_NAME="service_mesh-updated-in-$CLUSTER_NAME-$(date '+%s')"
  git checkout main 
  git pull origin main
  git checkout -b $BRANCH_NAME
  
  echo "Found $CLUSTER_NAME.yaml file to update."
  cat $CLUSTER_NAME.yaml

  if [ $ACTION = "add" ]; then 
    echo "Add service_mesh flag"
    cat $CLUSTER_NAME.yaml | yq '.values' | sed 's/^/  /' > values_part.yaml
    awk '/values: \|/{print $0; exit} {print}' $CLUSTER_NAME.yaml values_part.yaml > header_part.yaml
    cp header_part.yaml updated.yaml
    cat $CLUSTER_NAME.yaml | yq '.values' | yq '.istio_enabled = true | .certManager.enabled = true | .certManagerForISTIO.enabled = true | .istiod.enabled = true | .istioIngressGateway.enabled = true' | sed 's/^/  /' >> updated.yaml
    #     cat $CLUSTER_NAME.yaml | yq '.values' | yq '.istio_enabled = true | .certManager.enabled = true | .certManagerForISTIO.enabled = true | .istiod.enabled = true | .istioIngressGateway.enabled = true | .gateway.service.loadBalancerIp = env(LOAD_BALANCER_IP)' | sed 's/^/  /' >> updated.yaml
    cat updated.yaml > $CLUSTER_NAME.yaml
    
    echo "Result after adding service_mesh flag:"
    cat $CLUSTER_NAME.yaml 
  fi
  if [ $ACTION = "rm" ]; then 
    echo "Remove service_mesh flag"
    cat $CLUSTER_NAME.yaml | yq '.values' | sed 's/^/  /' > values_part.yaml
    awk '/values: \|/{print $0; exit} {print}' $CLUSTER_NAME.yaml values_part.yaml > header_part.yaml
    cp header_part.yaml updated.yaml
    cat $CLUSTER_NAME.yaml | yq '.values' | yq 'del(.istio_enabled) | del(.certManager) | del(.certManagerForISTIO) | del(.istiod) | del(.istioIngressGateway) | del(.gateway)' | sed 's/^/  /' >> updated.yaml
    cat updated.yaml > $CLUSTER_NAME.yaml

    echo "Result after removing service_mesh flag:"
    cat $CLUSTER_NAME.yaml 
  fi 

  git config user.name "FouadDevOps"
  git config user.email "algahmif@aetna.com"
  git add $CLUSTER_NAME.yaml
  COMMIT_ACTION="add"
  if [ $ACTION = "rm" ]; then
    COMMIT_ACTION="remove"
  fi
  if git status | grep -q "Changes to be committed"; then
    echo "Committing and pushing changes..."
    git commit -m "$COMMIT_ACTION service_mesh flag - $GITHUB_RUN_ID"
    git push -u origin $BRANCH_NAME
    gh pr create --fill
    gh pr merge $BRANCH_NAME --admin --squash
  fi 

fi
fi