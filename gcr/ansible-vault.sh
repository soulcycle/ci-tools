#!/bin/bash
# Ensures ansible-vault is installed within the build environment
#
# NOTE: This causes an error when running in Travis
#       DO NOT USE 'set -e' in this script, otherwise all hell breaks loose,
#       but, yaknow, without outputing the actual issue to the Travis log...

# Set TOOL_ROOT, the location of the directory this script is housed in
readonly TOOL_ROOT=$(cd $( dirname "${BASH_SOURCE[0]}" ) && pwd )

# Include shell helpers
source $TOOL_ROOT/utils.sh

echo_yellow "Ensuring ansible-vault is installed..."

IS_INSTALLED=$(which ansible-vault)

# Check if ansible-vault tools are installed
if [ $? -ne 0 ]; then
 echo_yellow "ansible-vault not installed, installing now..."

 sudo apt-get install software-properties-common -y
 sudo apt-add-repository ppa:ansible/ansible
 sudo apt-get update
 sudo apt-get install ansible -y

  echo_green "ansible-vault now installed."
else
  echo_green "ansible-vault was already installed."
fi

# Echo ansible-vault version
echo_green "ansible-vault version: "
ansible-vault --version
