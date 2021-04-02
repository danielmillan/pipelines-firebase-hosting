#!/bin/bash

set -eu

for arg in "$@"; do
    case $arg in
    --firebase-token=*)
        FIREBASE_TOKEN="${arg#*=}"
        ;;
    --project-name=*)
        PROJECT_NAME="${arg#*=}"
        ;;
    --resources-name=*)
        RESOURCES_NAME="${arg#*=}"
        ;;
    esac
    shift
done

showValidation() {
    echo "Make sure you are passing all required parameters:
        deploy-site.sh \\
            --firebase-token=(required) \\
            --resources-name=(required) \\
            --project-name=(required)
        
        You currently passed:
        --firebase-token: $FIREBASE_TOKEN
        --resources-name: $RESOURCES_NAME
        --project-name: $PROJECT_NAME
    " 1>&2

    exit 1
}

# Validate params
if [ -z "$FIREBASE_TOKEN" ] || [ -z "$RESOURCES_NAME" ] || [ -z "$PROJECT_NAME" ]; then
    showValidation
fi

# Install packages
npm ci
sed -i -e "s#NAME_DIR#$RESOURCES_NAME#g" ./firebase.json
sed -i -e "s#PROJECT#$PROJECT_NAME#g" ./firebaserc
# Create a target
echo "#### Deploying the site $PROJECT_NAME ####"
./node_modules/.bin/firebase target:apply hosting "$PROJECT_NAME" --token="$FIREBASE_TOKEN"
# Deploy site in firebase
./node_modules/.bin/firebase deslpoy --token="$FIREBASE_TOKEN" --only hosting:"$PROJECT_NAME"
echo "Site deploy !"