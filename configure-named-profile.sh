#!/bin/bash

# fail on any error
set -eu

# configure named profile
aws configure set aws_access_key_id $aws_access_key --profile $PROFILE_NAME
aws configure set aws_secret_access_key $aws_secret_key --profile $PROFILE_NAME
aws configure set region $aws_region --profile $PROFILE_NAME

# verify that profile is configured
aws configure list --profile $PROFILE_NAME
