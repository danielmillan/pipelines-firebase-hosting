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
    esac
    shift
done

showValidation() {
    echo "Make sure you are passing all required parameters:
        deploy-site.sh \\
            --firebase-token=(required) \\
            --project-name=(required)
        
        You currently passed:
        --firebase-token: $FIREBASE_TOKEN
        --project-name: $PROJECT_NAME
    " 1>&2

    exit 1
}

# Validate params
if [ -z "$FIREBASE_TOKEN" ] || [ -z "$PROJECT_NAME" ]; then
    showValidation
fi

# Install packages

echo "\n \n #### Installing firebase tools ####"
npm ci
echo "\n \n #### Firebase tools installed ####"