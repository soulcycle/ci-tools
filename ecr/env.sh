#!/bin/bash
# Sets up environment variables for use by other scripts
# 
# NOTE: Assumes the following env vars are defined within the running environment
#   - AWS_ACCT_NUMBER - The account number of the AWS account to push docker images to
#   - APP_NAME - The name of the application, and thus the ECR repository

set -e

# Set environment variables
export COMMIT_HASH=${TRAVIS_COMMIT:0:7}
export ECR_ARN="$AWS_ACCT_NUMBER.dkr.ecr.us-east-1.amazonaws.com/$APP_NAME"
