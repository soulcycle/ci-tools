#!/bin/bash
# Pushes a tagged image to GCR: PR-{pr-number-here}
#
# NOTE: Assumes the following env vars are defined within the running environment
#   - COMMIT_HASH - The first 7 characters of the travis commit hash
#   - DOCKER_TAG_BASE - The full URL of the GCR repository (including respository name) to push to
#                       NOTE: This can be overridden via the -b flag. See usage for more information.
#   - HARNESS_WEBHOOK - The full webhook URL to trigger a deploy in Harness
#   - HARNESS_APPLICATION_ID - Harness application ID
#   - HARNESS_SERVICE - Refers to a service that exists inside Harness. Example "W77"
# NOTE: Also assumes `gcr-login` has been run in order to successfully log in to GCR

# Set TOOL_ROOT, the location of the directory this script is housed in
readonly TOOL_ROOT=$(cd $( dirname "${BASH_SOURCE[0]}" ) && pwd )

# Include shell helpers
source $TOOL_ROOT/utils.sh

# Setup input variables
DOCKER_BASE="${DOCKER_TAG_BASE}"

# Main functionality of the script
main() {
  echo_yellow "Tagging and pushing for PR to ${DOCKER_BASE}..."

  # Create docker tag(s)
  docker tag $DOCKER_BASE:$COMMIT_HASH $DOCKER_BASE:PR-$TRAVIS_PULL_REQUEST

  # Push tag(s) to image repository
  docker push $DOCKER_BASE:PR-$TRAVIS_PULL_REQUEST

  echo_green "Pushed commit hash image PR-${TRAVIS_PULL_REQUEST} to ${DOCKER_BASE}."
  
  if [ -z "$HARNESS_WEBHOOK" ]; then
    echo_yellow "Letting Harness.io know a PR build happened..."

    curl -X POST -H 'Content-Type: application/json' \
    --url "${HARNESS_WEBHOOK}" \
    -d '{"application":"${HARNESS_APPLICATION_ID}","artifacts":[{"service":"${HARNESS_SERVICE}","buildNumber":"PR-${TRAVIS_PULL_REQUEST}"}]}'

    echo_green "Harness.io informed of PR build."
  fi
}

# Function that outputs usage information
usage() {
  cat <<EOF

Usage: $TOOL_ROOT/$(basename $0) <options>

Pushes a tagged image to GCR where the tag is PR-{pr-number-here}

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
