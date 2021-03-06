#!/bin/bash
# Attempts to log in to GCP via a service account
#
# NOTE: Assumes the following env vars are defined within the running environment
#   - GCLOUD_KEY - A base64-encoded service account .json private key,
#                  obtained via the service account creation process

set -e

# Set TOOL_ROOT, the location of the directory this script is housed in
readonly TOOL_ROOT=$(cd $( dirname "${BASH_SOURCE[0]}" ) && pwd )

# Include shell helpers
source $TOOL_ROOT/utils.sh

echo_yellow "Logging in to gcloud with service account..."

# Decode key and store temporarily, then try to activate it
echo $GCLOUD_KEY | base64 --decode > /tmp/sa.json

# Login with Docker
# https://cloud.google.com/container-registry/docs/advanced-authentication#json_key_file
docker login -u _json_key --password-stdin https://gcr.io < /tmp/sa.json

echo_green "Successfully logged in to gcloud with service account."

# Add SSH key to environments
ssh-keygen -f $HOME/.ssh/google_compute_engine -N ""

# Delete key
rm /tmp/sa.json
