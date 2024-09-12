#!/bin/bash

# fail on any error
set -eu

# configure named profile
aws configure set aws_access_key_id $TF_VAR_aws_access_key --profile $PROFILE_NAME
aws configure set aws_secret_access_key $TF_VAR_aws_secret_key --profile $PROFILE_NAME
aws configure set region $TF_VAR_aws_region --profile $PROFILE_NAME

# verify that profile is configured
aws configure list --profile $PROFILE_NAME
