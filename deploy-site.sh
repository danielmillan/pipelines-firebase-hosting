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

echo "#### Installing firebase tools ####"
npm ci
echo "#### Firebase tools installed ####"

echo "#### Starting site deployment ####"

echo "#### Creating a firebase target ####"
# Create a target
./node_modules/.bin/firebase target:apply hosting "$PROJECT_NAME" --token="$FIREBASE_TOKEN"
echo "#### Deploying the site $PROJECT_NAME ####"
# Deploy site in firebase
./node_modules/.bin/firebase deslpoy --token="$FIREBASE_TOKEN" --only hosting:"$PROJECT_NAME"