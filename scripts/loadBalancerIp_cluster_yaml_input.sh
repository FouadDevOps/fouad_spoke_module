set -e
 

if [ "$#" -ne 6 ]; then

  echo "ERROR: Incorrect number of arguments, received $#, but 6 are required"

  echo "Usage:"

  echo "$0 ACTION CLUSTER_NAME LOAD_BALANCER_IP RESOURCE_GROUP VNET_NAME SUBNET_NAME"

  for param in "$@"

  do

   echo "Received: " $param

  done

  exit 1

fi

 

ACTION=$1

CLUSTER_NAME=$2

LOAD_BALANCER_IP=$3

RESOURCE_GROUP=$4

VNET_NAME=$5

SUBNET_NAME=$6

 

if [ -z $LOAD_BALANCER_IP ]; then

  echo "Get an IP from the subnet"

  LOAD_BALANCER_IP=$(az network vnet subnet list-available-ips --resource-group $RESOURCE_GROUP --vnet-name $VNET_NAME --name $SUBNET_NAME --query [0])

  echo "Assigned IP: $LOAD_BALANCER_IP"

fi

echo "Paremeters in use:"

echo "ACTION: $ACTION"

echo "CLUSTER_NAME: $CLUSTER_NAME"

echo "LOAD_BALANCER_IP: $LOAD_BALANCER_IP"

 

echo "current working directory:"

pwd

cd ../../../../

echo "working directory:"

pwd

echo "Checking for cluster yaml file..."

if pwd | grep -q ECE-Managed-Envs; then

  echo "In ECE-Managed-Envs repo"

 

if ls | grep -q $CLUSTER_NAME.yaml; then

 

  BRANCH_NAME="loadBalancerIp/updated-in-$CLUSTER_NAME-$(date '+%s')"

  git checkout master

  git pull origin master

  git checkout -b $BRANCH_NAME

 

  echo "Found $CLUSTER_NAME.yaml file to update."

  cat $CLUSTER_NAME.yaml

  if [ $ACTION = "add" ]; then

    echo "Add loadBalancerIp flag"

    cat $CLUSTER_NAME.yaml | yq '.values' | sed 's/^/  /' > values_part.yaml

    ! diff --new-line-format="" --unchanged-line-format="" $CLUSTER_NAME.yaml values_part.yaml > header_part.yaml

    cp header_part.yaml updated.yaml

    cat $CLUSTER_NAME.yaml | yq '.values' | yq ".loadBalancerIp =$LOAD_BALANCER_IP" | sed 's/^/  /' >> updated.yaml

    cat updated.yaml > $CLUSTER_NAME.yaml

   

    echo "Result after adding loadBalancerIp flag:"

    cat $CLUSTER_NAME.yaml

  fi

  if [ $ACTION = "rm" ]; then

    echo "Remove loadBalancerIp flag"

    cat $CLUSTER_NAME.yaml | yq '.values' | sed 's/^/  /' > values_part.yaml

    ! diff --new-line-format="" --unchanged-line-format="" $CLUSTER_NAME.yaml values_part.yaml > header_part.yaml

    cp header_part.yaml updated.yaml

    cat $CLUSTER_NAME.yaml | yq '.values' | yq 'del(.loadBalancerIp)' | sed 's/^/  /' >> updated.yaml

    cat updated.yaml > $CLUSTER_NAME.yaml

 

    echo "Result after removing loadBalancerIp flag:"

    cat $CLUSTER_NAME.yaml

  fi

 

  git config user.name "ExpressCloud - Github Actions"

  git config user.email git@github.com

  git add $CLUSTER_NAME.yaml

  COMMIT_ACTION="add"

  if [ $ACTION = "rm" ]; then

    COMMIT_ACTION="remove"

  fi

  if git status | grep -q "Changes to be committed"; then

    echo "Committing and pushing changes..."

    git commit -m "$COMMIT_ACTION loadBalancerIp flag - $GITHUB_RUN_ID"

    git push -u origin $BRANCH_NAME

    gh pr create --fill

    gh pr merge $BRANCH_NAME --admin --squash

  fi

 

fi

fi