#!/bin/bash
# Sets up environment variables for use by other scripts
#
# NOTE: Assumes the following env vars are defined within the running environment
#   - APP_NAME - The name of the application, and thus the GCP repository
#
# NOTE: Assumes the following env vars MAY be defined within the running environment
#   - GCLOUD_ZONE - The zone to push GCR images to
#   - GCLOUD_PROJECTID - The GCP Project ID to push GCR images to
#                        NOTE: This is the Project ID, NOT the Project Name!

set -e

# Set environment variables
export COMMIT_HASH=${TRAVIS_COMMIT:0:7}
export CLOUDSDK_CORE_DISABLE_PROMPTS=1
export CLOUDSDK_COMPUTE_ZONE=${GCLOUD_ZONE:-us-east1-c}
export DOCKER_TAG_BASE=gcr.io/${GCLOUD_PROJECTID:-podium-prod}/$APP_NAME
