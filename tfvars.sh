#!/usr/bin/env sh

#########
#
# source this file to set environment variables:
#
#     source tfvars.sh
# 
# - depends on [pass](https://www.passwordstore.org/)
# 
# - replace values with hardcoded values if you aren't able to use pass
#
# - envfile included to set variables from Makefile 
# 
# note: default path for gcp_credentials_file is
#
#    ~/.config/gcloud/application_default_credentials.json
#
########## 

export TF_VAR_project=$(pass gcp_project)
export TF_VAR_email=$(pass gcp_email)
export TF_VAR_credentials_file=$(pass gcp_credentials_file)
export TF_VAR_notebooks_name=$(pass gcp_notebooks_name)
echo "TF_VAR_project=$(pass gcp_project)" > envfile
echo "TF_VAR_email=$(pass gcp_email)" >> envfile
echo "TF_VAR_credentials_file=$(pass gcp_credentials_file)" >> envfile
echo "TF_VAR_notebooks_name=$(pass gcp_notebooks_name)" >> envfile