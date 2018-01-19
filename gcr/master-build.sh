#!/bin/bash
# Pushes two tagged images to GCR: master and latest
#
# NOTE: Assumes the following env vars are defined within the running environment
#   - COMMIT_HASH - The first 7 characters of the travis commit hash
#   - DOCKER_TAG_BASE - The full ARN of the GCR repository (including respository name)
#
# NOTE: Also assumes `gcr-login` has been run in order to successfully log in to GCR

set -e

# Set TOOL_ROOT, the location of the directory this script is housed in
readonly TOOL_ROOT=$(cd $( dirname "${BASH_SOURCE[0]}" ) && pwd )

# Include shell helpers
source $TOOL_ROOT/utils.sh

echo_yellow "Tagging and pushing a master push to $DOCKER_TAG_BASE..."

# Create docker tag(s)
docker tag $DOCKER_TAG_BASE:$COMMIT_HASH $DOCKER_TAG_BASE:master
docker tag $DOCKER_TAG_BASE:$COMMIT_HASH $DOCKER_TAG_BASE:latest

# Push tag(s) to image repository
gcloud docker -- push $DOCKER_TAG_BASE:master > /dev/null
gcloud docker -- push $DOCKER_TAG_BASE:latest > /dev/null

echo_green "Pushed commit hash image for master to $DOCKER_TAG_BASE."
