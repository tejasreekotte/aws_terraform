#!/bin/bash
BUILD_ID=$(echo "${CODEBUILD_BUILD_ID}" | tr -dc 'a-zA-Z0-9-')
# fail on any error
set -eu

# go back to the previous directory
cd bucket

# initialize terraform
terraform init

# # apply terraform
terraform apply -auto-approve -var "build_id=${BUILD_ID}"
