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

DOCKER_REPO=$ECR_ARN
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -r|--repo)
    DOCKER_REPO="$2"
    shift # past argument
    shift # past value
    ;;    
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}"
echo $DOCKER_REPO;
if [ -z "$DOCKER_REPO" ]; then
	echo "No Docker Repository Specified"
	exit 1
fi

echo "Tagging and pushing to $DOCKER_REPO"

# Create docker tag(s)
docker tag $DOCKER_REPO:$COMMIT_HASH $ECR_ARN:$TRAVIS_TAG
docker tag $DOCKER_REPO:$COMMIT_HASH $ECR_ARN:stable

# Push tag(s) to image repository
docker push $DOCKER_REPO:$TRAVIS_TAG
docker push $DOCKER_REPO:stable
