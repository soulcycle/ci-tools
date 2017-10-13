#!/bin/bash
# Pushes two tagged images to ECR: master and latest
# 
# NOTE: Assumes the following env vars are defined within the running environment
#   - ECR_ARN - The full ARN of the ECR repository (including respository name)
#   - COMMIT_HASH - The first 7 characters of the travis commit hash
#   
# NOTE: Also assumes `ecr-login` has been run in order to successfully log in to ECR

set -e

DIR=$(dirname $0)

source $DIR/utils.sh

echo "Building for master"

# By default use $ECR_ARN
DOCKER_REPO=$ECR_ARN
# Read any overrides that came in from cli
readArgOverrides $@

if [ -z "$DOCKER_REPO" ]; then
	echo "No Docker Repository Specified"
	exit 1
fi

echo "Tagging and pushing to $DOCKER_REPO"

# Create docker tag(s)
docker tag $DOCKER_REPO:$COMMIT_HASH $ECR_ARN:master
docker tag $DOCKER_REPO:$COMMIT_HASH $ECR_ARN:latest

# Push tag(s) to image repository
docker push $DOCKER_REPO:master
docker push $DOCKER_REPO:latest