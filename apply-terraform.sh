#!/bin/bash
TIMESTAMP=$(date +"%Y%m%d%H%M%S")

# fail on any error
set -eu

# Check the resource type and navigate to the correct directory
if [ "${resource_type}" == "bucket" ]; then
    cd bucket
elif [ "${resource_type}" == "vm" ]; then
    cd vm
else
    echo "Unknown resource type: ${resource_type}"
    exit 1
fi

# Initialize Terraform
terraform init

# Apply Terraform with the timestamp variable
terraform apply -auto-approve -var "timestamp=${TIMESTAMP}"
