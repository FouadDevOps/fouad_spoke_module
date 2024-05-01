set -e
 

if [ "$#" -ne 3 ]; then

  echo "ERROR: Incorrect number of arguments, received $#, but 6 are required"

  echo "Usage:"

  echo "$0 ACTION CLUSTER_NAME SERVICE_MESH"

  for param in "$@"

  do

   echo "Received: " $param

  done

  exit 1

fi

 

ACTION=$1
CLUSTER_NAME=$2
SERVICE_MESH=$3
 

echo "Paremeters in use:"

echo "ACTION: $ACTION"

echo "CLUSTER_NAME: $CLUSTER_NAME"

echo "SERVICE_MESH: $LOAD_BALANCER_IP"

 

echo "current working directory:"

pwd

cd ../../../../

echo "working directory:"

pwd

echo "Checking for cluster yaml file..."

if pwd | grep -q managed-environment; then

  echo "In managed-environment repo"

 

if ls | grep -q $CLUSTER_NAME.yaml; then

 

  BRANCH_NAME="service_mesh/updated-in-$CLUSTER_NAME-$(date '+%s')"

  git checkout main

  git pull origin main

  git checkout -b $BRANCH_NAME

 

  echo "Found $CLUSTER_NAME.yaml file to update."

  cat $CLUSTER_NAME.yaml

  if [ $ACTION = "add" ]; then

    echo "Add service_mesh flag"

    cat $CLUSTER_NAME.yaml | yq '.values' | sed 's/^/  /' > values_part.yaml

    awk '/values: \|/{print $0; exit} {print $0}' $CLUSTER_NAME.yaml values_part.yaml > header_part.yaml

    cp header_part.yaml updated.yaml

    cat $CLUSTER_NAME.yaml | yq '.values' | yq '.istio_enabled = true'| sed 's/^/  /' >> updated.yaml

    cat updated.yaml > $CLUSTER_NAME.yaml

   

    echo "Result after adding service_mesh flag:"

    cat $CLUSTER_NAME.yaml

  fi

  if [ $ACTION = "rm" ]; then

    echo "Remove service_mesh flag"

    cat $CLUSTER_NAME.yaml | yq '.values' | sed 's/^/  /' > values_part.yaml

    awk '/values: \|/{print $0; exit} {print $0}' $CLUSTER_NAME.yaml values_part.yaml > header_part.yaml

    cp header_part.yaml updated.yaml

    cat $CLUSTER_NAME.yaml | yq '.values' | yq 'del(.istio_enabled)' | sed 's/^/  /' >> updated.yaml

    cat updated.yaml > $CLUSTER_NAME.yaml

 

    echo "Result after removing service_mesh flag:"

    cat $CLUSTER_NAME.yaml

  fi

 

  git config user.name "FouadDevOps - Github Actions"

  git config user.email algahmif@aetna.com

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