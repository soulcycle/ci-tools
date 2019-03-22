#!/bin/bash
# Attempts to confirm that any pops secrets are decryptable as expected.
#
# NOTE: Assumes the following env vars are defined within the running environment
#   - POPS_ANSIBLE_PASSWORD - Shared secret that's used to decrypt the contents of secrets.yml files
#   - TRAVIS_BUILD_DIR - Base working directory for the build environment
#   - VAULT_PWD_FILE_PATH - Path to the Vault password file that's mounted into the ansible-vault 
#                           utility container

# Temporarily provision vault key file
echo "Building temporary secrets file."
touch vault.log && chmod a-x vault.log
echo "${POPS_ANSIBLE_PASSWORD}" > $TRAVIS_BUILD_DIR/vault.log

# Pull down the latest image
echo "Pulling latest ansible-vault utility container image... "
docker pull gcr.io/podium-production/ansible-vault:latest

echo "Running Pops secret validation ... "
echo "${POPS_ANSIBLE_PASSWORD}" > $TRAVIS_BUILD_DIR/vault.log

docker run --entrypoint /bin/bash -it \
    -v ${TRAVIS_BUILD_DIR}/vault.log:/home/secrets/vault.log \
    -v ${TRAVIS_BUILD_DIR}/provisioning/k8s/:/home/secrets \
    -v /tmp/build/misc/vault-secrets.sh:/home/secrets/vault-secrets.sh \
        gcr.io/podium-production/ansible-vault:latest /home/secrets/vault-secrets.sh

if [ $? != 0 ]; then
    echo "Secret validation process exited with an error."
    rm vault.log
    exit 1;
fi

echo "All secrets have been confirmed to be encrypted as expected!"
rm vault.log
exit 0
