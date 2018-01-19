#!/bin/bash
# Ensures GCloud CLI tools are installed within the build environment
#
# NOTE: This causes an error when running in Travis
#       DO NOT USE 'set -e' in this script, otherwise all hell breaks loose,
#       but, yaknow, without outputing the actual issue to the Travis log...

# Set TOOL_ROOT, the location of the directory this script is housed in
readonly TOOL_ROOT=$(cd $( dirname "${BASH_SOURCE[0]}" ) && pwd )

# Include shell helpers
source $TOOL_ROOT/utils.sh

echo_yellow "Ensuring gcloud is installed..."

# Re-own python install directory
sudo chown -R $(whoami) /usr/local

# Upgrade pip
pip install --upgrade pip

# Install pip dependencies
pip install pyopenssl

# Check if gcloud tools are installed
if [ ! -d $HOME/google-cloud-sdk ]; then
  echo_yellow "gcloud not installed, installing now..."

  curl https://sdk.cloud.google.com | bash;
  $HOME/google-cloud-sdk/bin/gcloud components update preview

  echo_green "gcloud now installed."
else
  echo_green "gcloud was already installed."
fi

# Echo gcloud version
echo_green "gcloud version: "
gcloud version
