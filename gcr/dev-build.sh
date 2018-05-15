#!/bin/bash
# Pushes a tagged images to GCR: dev
#
# NOTE: Assumes the following env vars are defined within the running environment
#   - COMMIT_HASH - The first 7 characters of the travis commit hash
#   - DOCKER_TAG_BASE - The full URL of the GCR repository (including respository name) to push to
#                       NOTE: This can be overridden via the -b flag. See usage for more information.
#
# NOTE: Also assumes `gcr-login` has been run in order to successfully log in to GCR

# Set TOOL_ROOT, the location of the directory this script is housed in
readonly TOOL_ROOT=$(cd $( dirname "${BASH_SOURCE[0]}" ) && pwd )

# Include shell helpers
source $TOOL_ROOT/utils.sh

# Setup input variables
DOCKER_BASE="${DOCKER_TAG_BASE}"

# Main functionality of the script
main() {
  echo_yellow "Tagging and pushing a dev push to ${DOCKER_BASE}..."

  # Create docker tag(s)
  docker tag $DOCKER_BASE:$COMMIT_HASH $DOCKER_BASE:dev

  # Push tag(s) to image repository
  docker push $DOCKER_BASE:dev

  echo_green "Pushed commit hash image for dev to ${DOCKER_BASE}."
}

# Function that outputs usage information
usage() {
  cat <<EOF

Usage: $TOOL_ROOT/$(basename $0) <options>

Pushes a tagged images to GCR: dev

Options:
  -b     The full URL of the GCR repository (including respository name) to push to
         NOTE: Use this flag to override the default behavior,
         which uses the DOCKER_TAG_BASE environment variable
  -h     Print this message and quit

EOF
  exit 0
}

# Parse input options
while getopts ":b:h-:" opt; do
  case "$opt" in
    b) DOCKER_BASE=$OPTARG;;
    h) usage;;
    \?) echo_red "Invalid option: -$OPTARG." && usage;;
    :) die "Option -$OPTARG requires an argument.";;
  esac
done

# Execute main functionality
main
