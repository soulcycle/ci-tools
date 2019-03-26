# How to run:


```
docker run \
    -v ${TRAVIS_BUILD_DIR}/vault.log:/tmp/vault.log \
    -v ${TRAVIS_BUILD_DIR}/provisioning/k8s/:/home/secrets \
    -v /tmp/build/misc/helpers.py:/usr/src/app/helpers.py \
    -v /tmp/build/misc/secretvalidator.py:/usr/src/app/secretvalidator.py \
    -v /tmp/build/misc/inspect-k8s-manifests.py:/usr/src/app/inspect-k8s-manifests.py \
        gcr.io/podium-production/ansible-vault:latest
```

Note: 

* The volumes are added to the above command to always put the latest scripts into the container image. A version of them exists in the base image too.
