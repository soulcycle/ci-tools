#!/bin/bash
# Decrypts firebase keys that are inside utils/firebase-keys directory

# Set TOOL_ROOT, the location of the directory this script is housed in
readonly TOOL_ROOT=$(cd $( dirname "${BASH_SOURCE[0]}" ) && pwd )

# Include shell helpers
source $TOOL_ROOT/utils.sh

# Decode ansible firebase keys
echo "$ANSIBLE_FIREBASE_PASSWORD" | base64 -d > /tmp/ansible_password.txt

# Decrypt ansible firebase keys
ansible-vault decrypt $TRAVIS_BUILD_DIR/utils/firebase-keys/* --vault-password-file=/tmp/ansible_password.txt

# Check if decryption was successful
if [[ $? -ne 0 ]] ; then
  echo_red "Decryption has failed"
fi

# Remove temporal key
rm /tmp/ansible_password.txt
