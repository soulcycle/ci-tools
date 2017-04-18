#!/bin/bash
# Pushes a new semver-tagged image to ECR: X.X.X (major/minor/patch)
# 
# NOTE: Assumes the following env vars are defined within the running environment
#   - ECR_ARN - The full ARN of the ECR repository (including respository name)
#   - COMMIT_HASH - The first 7 characters of the travis commit hash
#   - TRAVIS_TAG - The semver tag travis has given this build
#   
# NOTE: Also assumes `ecr-login` has been run in order to successfully log in to ECR

set -e

echo "Building for semver"

# Create docker tag(s)
docker tag $ECR_ARN:$COMMIT_HASH $ECR_ARN:$TRAVIS_TAG
docker tag $ECR_ARN:$COMMIT_HASH $ECR_ARN:stable

# Push tag(s) to image repository
docker push $ECR_ARN:$TRAVIS_TAG
docker push $ECR_ARN:stable
