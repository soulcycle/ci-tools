#!/bin/bash
# Attempts to confirm that any pops secrets are decryptable as expected.
#
# NOTE: Assumes the following env vars are defined within the running environment
#   - POPS_ANSIBLE_PASSWORD - Shared secret that's used to decrypt the contents of secrets.yml files
#   - TRAVIS_BUILD_DIR - Base working directory for the build environment

# Temporarily provision vault key file
echo "Building temporary secrets file."
touch vault.log && chmod 600 vault.log
echo "${POPS_ANSIBLE_PASSWORD}" > $TRAVIS_BUILD_DIR/vault.log

# Pull down the latest image
echo "Pulling latest ansible-vault utility container image... "
docker pull gcr.io/podium-production/ansible-vault:latest

echo "Running Pops secret validation ... "
decrypted=$(echo "${POPS_ANSIBLE_PASSWORD}" | base64 -d)
echo $decrypted > $TRAVIS_BUILD_DIR/vault.log

docker run \
    -v ${TRAVIS_BUILD_DIR}/vault.log:/tmp/vault.log \
    -v ${TRAVIS_BUILD_DIR}/provisioning/k8s/:/home/secrets \
    -v /tmp/build/misc/helpers.py:/usr/src/app/helpers.py \
    -v /tmp/build/misc/secretvalidator.py:/usr/src/app/secretvalidator.py \
    -v /tmp/build/misc/inspect-k8s-manifests.py:/usr/src/app/inspect-k8s-manifests.py \
        gcr.io/podium-production/ansible-vault:latest

if [ $? != 0 ]; then
    echo "Secret validation process exited with an error."
    rm vault.log
    exit 1;
fi

echo "All secrets have been confirmed to be encrypted as expected!"
rm vault.log
exit 0
