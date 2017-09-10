#!/bin/bash
# Installs AWS CLI tools and attempts to log in to ECR
# 
# NOTE: Assumes the following env vars are defined within the running environment
#   - AWS_ACCESS_KEY_ID - The ID of the AWS access key
#   - AWS_SECRET_ACCESS_KEY - The secret of the AWS access key
#   - AWS_DEFAULT_REGION - The default AWS region to be used for CLI requests

set -e

# Re-own python install directory
sudo chown -R $(whoami) /usr/local

# Upgrade pip
pip install --upgrade pip

# Install pip dependencies
pip install awscli

# Login to ECR
eval $(aws ecr get-login)
