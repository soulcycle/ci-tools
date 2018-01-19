#!/bin/bash
# Pushes a tagged image to GCR: PR-{pr-number-here}
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

echo_yellow "Tagging and pushing for PR to $DOCKER_TAG_BASE..."

# Create docker tag(s)
docker tag $DOCKER_TAG_BASE:$COMMIT_HASH $DOCKER_TAG_BASE:PR-$TRAVIS_PULL_REQUEST

# Push tag(s) to image repository
gcloud docker -- push $DOCKER_TAG_BASE:PR-$TRAVIS_PULL_REQUEST > /dev/null

echo_green "Pushed commit hash image PR-$TRAVIS_PULL_REQUEST to $DOCKER_TAG_BASE."
