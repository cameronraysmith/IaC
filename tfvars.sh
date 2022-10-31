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
# - .env included to set variables from Makefile 
# 
# note: default path for gcp_credentials_file is
#
#    ~/.config/gcloud/application_default_credentials.json
#
########## 

# set -xv

if ! command -v gh
then
    echo "github cli could not be found"
    echo "please see https://cli.github.com/ for installation instructions"
    echo "or set the following variables manually"
    echo "STARTUP_SCRIPT_GIST_ID to use a gist for startup script"
    echo "or TF_VAR_post_startup_script_url to use another publicly accessible url"
    exit 1
fi

if ! command -v pass
then
    echo "pass could not be found"
    echo "please see https://www.passwordstore.org/ for installation instructions"
    echo "or set all variables using pass manually"
    exit 1
fi

GITHUB_USERNAME=$(pass github_username)
export GITHUB_ORG_NAME=$(pass github_org)
export GITHUB_REPO_NAME=$(pass github_repo)
STARTUP_SCRIPT_NAME="post-startup-script.sh"

cat template-post-startup-script.sh | \
envsubst '${GITHUB_ORG_NAME} ${GITHUB_REPO_NAME}' > $STARTUP_SCRIPT_NAME

get_startup_script_gist_id () {
   echo "$(gh gist list | grep -m1 '.*post-startup-script.*' | cut -f1)"
}

temp_gist_id=$(get_startup_script_gist_id)
if [ -z "$temp_gist_id" ]; then
   echo "$temp_gist_id"
   echo "no gist matching pattern 'post-startup-script'"
   echo "creating gist from $STARTUP_SCRIPT_NAME"
   gh gist create "$STARTUP_SCRIPT_NAME"
else
   echo "updating gist $temp_gist_id from local $STARTUP_SCRIPT_NAME"
   gh gist edit "$temp_gist_id" "$STARTUP_SCRIPT_NAME"
fi


STARTUP_SCRIPT_GIST_ID="$(get_startup_script_gist_id)"
echo "startup script gist id: $STARTUP_SCRIPT_GIST_ID"
TF_VAR_project="$(pass gcp_project)"
TF_VAR_email="$(pass gcp_email)"
TF_VAR_credentials_file="$(pass gcp_credentials_file)"
TF_VAR_notebooks_name="$(pass gcp_notebooks_name)"
TF_VAR_post_startup_script_url="https://gist.githubusercontent.com/$GITHUB_USERNAME/$STARTUP_SCRIPT_GIST_ID/raw/$STARTUP_SCRIPT_NAME"
export TF_VAR_project TF_VAR_email TF_VAR_credentials_file TF_VAR_notebooks_name TF_VAR_post_startup_script_url
# unset TF_VAR_project TF_VAR_email TF_VAR_credentials_file TF_VAR_notebooks_name TF_VAR_post_startup_script_url GITHUB_ORG_NAME GITHUB_REPO_NAME

url_status=$(curl -s -o /dev/null -w "%{http_code}" "$TF_VAR_post_startup_script_url")
echo "post startup script url: $TF_VAR_post_startup_script_url"
echo "view post startup script in stdout: gh gist view $STARTUP_SCRIPT_GIST_ID"
echo "check startup script gists with: gh gist list | grep '.*post-startup-script.*'"
echo "post startup script url status: $url_status"

{
    echo "TF_VAR_project=$TF_VAR_project";
    echo "TF_VAR_email=$TF_VAR_email";
    echo "TF_VAR_credentials_file=$TF_VAR_credentials_file";
    echo "TF_VAR_notebooks_name=$TF_VAR_notebooks_name";
    echo "TF_VAR_post_startup_script_url=$TF_VAR_post_startup_script_url";
    echo "GITHUB_ORG_NAME=$GITHUB_ORG_NAME";
    echo "GITHUB_REPO_NAME=$GITHUB_REPO_NAME";
} > .env