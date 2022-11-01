#############
# makefile for terraform google_notebooks_instance
#
# see README.md for usage
#
# prerequisites:
#
# - install gcloud sdk
#   - gcloud init # set project
# 	- gcloud auth login
# 	- gcloud auth application-default login
#
# - install terraform
# 	- terraform init
#
# - install gh cli
#   - gh auth login
#   - gh auth status
#
# - edit dotenv-gen.sh
# 	- set variables using [pass][pass] or manually
#
# - review/edit terraform.tfvars
#
# [pass]: https://www.passwordstore.org/
#
# usage: 
#
#     make up - create -OR- update the instance
# 	  make stop - stop the instance
# 	  make start - start the instance
#     make down - delete the instance
#
# all other targets are auxiliary
##############

# set variables with shell scripts
# or manually edit .env and
# remove/comment the following line(s)
$(shell ./dotenv-gen.sh > /dev/null 2>&1)
$(shell ./startup-script-gen.sh > /dev/null 2>&1)
include .env
export


up: \
apply \
update_os_login \
info \
config_ssh

stop:
	gcloud compute instances stop $(TF_VAR_notebooks_name)

start: \
start_instance \
info \
config_ssh

down:
	terraform destroy -auto-approve

############################################
############################################

setup: test
	terraform fmt
	terraform validate
	terraform plan -out=tfplan

apply: setup
	terraform apply -auto-approve "tfplan" 

info:
	gcloud compute instances list
	@echo "\nsee the following url\n\n== https://console.cloud.google.com/vertex-ai/workbench/list/instances?project=$(TF_VAR_project) ==\n\nfor running instances and connection to jupyter server\n"

# see .ssh/config or similar for ssh config
config_ssh:
	gcloud compute config-ssh

start_instance:
	gcloud compute instances start $(TF_VAR_notebooks_name)

# list names of images available in the deeplearning-platform-release
show_disk_images:
	gcloud compute images list --project=deeplearning-platform-release

show_container_images:
	gcloud container images list --repository="gcr.io/deeplearning-platform-release"

# to be removed when tf google_notebooks_instance API supports enable-oslogin
update_os_login:
	gcloud compute instances add-metadata $(TF_VAR_notebooks_name) --metadata=enable-oslogin="FALSE"
	gcloud compute instances describe $(TF_VAR_notebooks_name) --format="value(metadata)"

delete_gist:
	@echo "github gist ID to be removed: $(GITHUB_STARTUP_SCRIPT_GIST_ID)"
	gh gist delete $(GITHUB_STARTUP_SCRIPT_GIST_ID)

# relevant when using container, as opposed to vm, images
restart_container:
	gcloud compute ssh $(TF_VAR_notebooks_name) --command 'docker restart payload-container'

test:
	env | grep "TF_VAR\|GITHUB"


############################################
############################################