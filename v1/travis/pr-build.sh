#!/bin/bash
# Pushes a new tagged image to ECR: PR-{pr-number-here}
# 
# NOTE: Assumes the following env vars are defined within the running environment
#   - ECR_ARN - The full ARN of the ECR repository (including respository name)
#   - COMMIT_HASH - The first 7 characters of the travis commit hash
#   - TRAVIS_PULL_REQUEST - The pull request number aassociated with this build
#   
# NOTE: Also assumes `ecr-login` has been run in order to successfully log in to ECR

set -e

echo "Building for PR"

# Create docker tag(s)
docker tag $ECR_ARN:$COMMIT_HASH $ECR_ARN:PR-$TRAVIS_PULL_REQUEST

# Push tag(s) to image repository
docker push $ECR_ARN:PR-$TRAVIS_PULL_REQUEST
