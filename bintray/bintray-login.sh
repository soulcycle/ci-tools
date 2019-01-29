#!/bin/bash
# Attempts to log in to bintray using an api key
#
# NOTE: Assumes the following env vars are defined within the running environment
#   - BINTRAY_USER - bintray user
#   - BINTRAY_KEY - bintray api key
#   - BINTRAY_REPO - A bintray repo name

set -e

# Set TOOL_ROOT, the location of the directory this script is housed in
readonly TOOL_ROOT=$(cd $( dirname "${BASH_SOURCE[0]}" ) && pwd )

# Include shell helpers
# In travis, all the scripts end up in /tmp/build
source utils.sh

echo_yellow "Logging in to bintray with an api key..."

# Login with Docker
echo "$BINTRAY_KEY" | docker login -u $BINTRAY_USER --password-stdin $BINTRAY_REPO

echo_green "Successfully logged in to bintray with an api key."
