#!/bin/bash
# Pushes two tagged images to ECR: master and latest
# 
# NOTE: Assumes the following env vars are defined within the running environment
#   - ECR_ARN - The full ARN of the ECR repository (including respository name)
#   - COMMIT_HASH - The first 7 characters of the travis commit hash
#   
# NOTE: Also assumes `ecr-login` has been run in order to successfully log in to ECR

set -e

echo "Building for master"

# Create docker tag(s)
docker tag $ECR_ARN:$COMMIT_HASH $ECR_ARN:master
docker tag $ECR_ARN:$COMMIT_HASH $ECR_ARN:latest

# Push tag(s) to image repository
docker push $ECR_ARN:master
docker push $ECR_ARN:latest
