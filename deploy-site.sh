#!/bin/bash

set -e

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
    --target-name=*)
        TARGET_NAME="${arg#*=}"
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
            --project-name=(optional)
        
        You currently passed:
        --firebase-token: $FIREBASE_TOKEN
        --resources-name: $RESOURCES_NAME
        --project-name: $PROJECT_NAME
        --target-name: $TARGET_NAME
    " 1>&2

    exit 1
}

# Validate params
if [ -z "$FIREBASE_TOKEN" ] || [ -z "$RESOURCES_NAME" ] || [ -z "$PROJECT_NAME" ]; then
    showValidation
fi

# Install firebase CLI
npm i -g firebase-tools

# Copy files config
cp ./.github/actions/pipelines-firebase-hosting/.firebaserc ./
cp ./.github/actions/pipelines-firebase-hosting/firebase.json ./

# Set project info
sed -i -e "s#NAME_DIR#$RESOURCES_NAME#g" ./firebase.json
sed -i -e "s#PROJECT#$PROJECT_NAME#g" ./.firebaserc

# Validate clausule to create a target
if [ ! -z "$TARGET_NAME" ]; then
    firebase target:apply hosting "$TARGET_NAME" "$TARGET_NAME"
    firebase deploy --token="$FIREBASE_TOKEN" --only hosting:"$TARGET_NAME"
else
    firebase deploy --token="$FIREBASE_TOKEN" --only hosting
fi;
