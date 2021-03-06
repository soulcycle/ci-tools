#!/bin/bash
# Pushes a semver-tagged image to GCR: X.X.X (major/minor/patch)
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
  echo_yellow "Tagging and pushing a semver tag to ${DOCKER_BASE}..."

  # Create docker tag(s)
  docker tag $DOCKER_BASE:$COMMIT_HASH $DOCKER_BASE:$TRAVIS_TAG
  docker tag $DOCKER_BASE:$COMMIT_HASH $DOCKER_BASE:stable

  # Push tag(s) to image repository
  docker push $DOCKER_BASE:$TRAVIS_TAG
  docker push $DOCKER_BASE:stable

  echo_green "Pushed commit hash image for a semver tag to ${DOCKER_BASE}."

  # Parse out JIRA Tickets to send to Harness
  PREVIOUS_TAG=$(git describe --abbrev=0 --tags `git rev-list --tags --skip=1 --max-count=1`)
  PATTERN="PE-[[:digit:]]*"
  JIRA_TICKETS=[$(git diff ${PREVIOUS_TAG} -- CHANGELOG.md | grep -o ${PATTERN})]

  if [ -n "$HARNESS_WEBHOOK_SEMVER" ]; then
    echo_yellow "Letting Harness.io know a semver build happened..."

    curl -X POST -H 'Content-Type: application/json' \
    --url "${HARNESS_WEBHOOK_SEMVER}" \
    -d "{\"application\":\"${HARNESS_APPLICATION_ID}\",\"artifacts\":[{\"service\":\"${HARNESS_SERVICE}\",\"buildNumber\":\"${TRAVIS_TAG}\",\"jiraTickets\":\"${JIRA_TICKETS}\"}]}"

    echo_green "\n Harness.io informed of semver build."
  fi
}

# Function that outputs usage information
usage() {
  cat <<EOF

Usage: $TOOL_ROOT/$(basename $0) <options>

Pushes a semver-tagged image to GCR: X.X.X (major/minor/patch)

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
