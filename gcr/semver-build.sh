#!/bin/bash
# Pushes a new semver-tagged image to GCR: X.X.X (major/minor/patch)
#
# NOTE: Assumes the following env vars are defined within the running environment
#   - COMMIT_HASH - The first 7 characters of the travis commit hash
#   - DOCKER_TAG_BASE - The full ARN of the GCR repository (including respository name)
#
# NOTE: Also assumes `gcr-login` has been run in order to successfully log in to GCR

# Set TOOL_ROOT, the location of the directory this script is housed in
readonly TOOL_ROOT=$(cd $( dirname "${BASH_SOURCE[0]}" ) && pwd )

# Include shell helpers
source $TOOL_ROOT/utils.sh

echo_yellow "Tagging and pushing a semver tag to $DOCKER_TAG_BASE..."

# Create docker tag(s)
docker tag $DOCKER_TAG_BASE:$COMMIT_HASH $DOCKER_TAG_BASE:$TRAVIS_TAG
docker tag $DOCKER_TAG_BASE:$COMMIT_HASH $DOCKER_TAG_BASE:stable

# Push tag(s) to image repository
gcloud docker -- push $DOCKER_TAG_BASE:$TRAVIS_TAG > /dev/null
gcloud docker -- push $DOCKER_TAG_BASE:stable > /dev/null

echo_green "Pushed commit hash image for a semver tag to $DOCKER_TAG_BASE."
