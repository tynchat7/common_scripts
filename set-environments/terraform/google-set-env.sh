#!/bin/bash -e 

DATAFILE="$PWD/$1"
#
# FuchiCorp common script to set up Google terraform environment variables
# these all variables should be created on your config file before you run script.
# <ENVIRONMENT> <BUCKET> <DEPLOYMENT> <PROJECT> <CREDENTIALS>

if [ -z "$GIT_TOKEN" ]
then
  echo """
  Script needs github token to get private repos.
  Github <GIT_TOKEN> not found."""
  return 1 
fi

PROJECT=$(sed -nr 's/^google_project_id\s*=\s*"([^"]*)".*$/\1/p'            "$DATAFILE")
BUCKET=$(sed -nr 's/^google_bucket_name\s*=\s*"([^"]*)".*$/\1/p'            "$DATAFILE")
ENVIRONMENT=$(sed -nr 's/^deployment_environment\s*=\s*"([^"]*)".*$/\1/p'   "$DATAFILE")
DEPLOYMENT=$(sed -nr 's/^deployment_name\s*=\s*"([^"]*)".*$/\1/p'           "$DATAFILE")
CREDENTIALS=$(sed -nr 's/^credentials\s*=\s*"([^"]*)".*$/\1/p'              "$DATAFILE")

if [ ! -f "$DATAFILE" ]; then
  echo "setenv: Configuration file not found: $DATAFILE"
  return 1
fi

if [ -z "$PROJECT" ]
then
    echo "setenv: 'google_project_id' variable not set in configuration file."
fi

if [ -z "$BUCKET" ]
then
  echo "setenv: 'google_bucket_name' variable not set in configuration file."
fi

if [ -z "$ENVIRONMENT" ]
then
    echo "setenv: 'deployment_environment' variable not set in configuration file."
    return 1
fi

if [ -z "$BUCKET" ]
then
  echo "setenv: 'google_bucket_name' variable not set in configuration file."
  return 1
fi

if [ -z "$PROJECT" ]
then
    echo "setenv: 'google_project_id' variable not set in configuration file."
    return 1
fi

if [ -z "$CREDENTIALS" ]
then
    echo "setenv: 'credentials' file not set in configuration file."
    return 1
fi

if [ -z "$DEPLOYMENT" ]
then
    echo "setenv: 'deployment_name' variable not set in configuration file."
    return 1
fi

cat << EOF > "$PWD/backend.tf"
terraform {
  backend "gcs" {
    bucket  = "${BUCKET}"
    prefix  = "${ENVIRONMENT}/${DEPLOYMENT}"
    project = "${PROJECT}"
  }
}
EOF
cat "$PWD/backend.tf"

GOOGLE_APPLICATION_CREDENTIALS="${PWD}/${CREDENTIALS}"
export GOOGLE_APPLICATION_CREDENTIALS
export DATAFILE
/bin/rm -rf "$PWD/.terraform" 2>/dev/null
echo "setenv: Initializing terraform"
terraform init #> /dev/null

