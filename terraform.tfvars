##########
# public variables
##########

# see tfvars.sh for private variables

##########
# machine
##########

# notebooks_name        = <see TF_VAR_notebooks_name>
notebook_machine_type = "n1-standard-4"

# image-based
vm_image_project = "deeplearning-platform-release"
vm_image_family  = "pytorch-1-12-cu113-notebooks"

# container-based
# container_image       = "gcr.io/deeplearning-platform-release/pytorch-gpu"
# container_tag         = "latest"
# container_image       = "docker.io/cameronraysmith/notebooks"
# container_tag         = "develop"
# container_image       = "nvcr.io/nvidia/pytorch"
# container_tag         = "22.09-py3"

# startup script
post_startup_script_url = "https://hastebin.com/raw/oyifewenub"
# post_startup_script_url = "https://hastebin.com/raw/ledahubuqe" # test


##########
# disks
##########

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/notebooks_instance#boot_disk_type
boot_disk_size_gb = 100
boot_disk_type    = "PD_STANDARD"
data_disk_size_gb = 100
data_disk_type    = "PD_STANDARD"


#########
# accelerator
#########

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/notebooks_instance#type
install_gpu_driver = true
accelerator_type   = "NVIDIA_TESLA_T4"
accelerator_number = 1


#########
# location
#########

# toggle based on availability
# https://cloud.google.com/vertex-ai/docs/general/locations#user-managed-notebooks-locations
# region                  = "us-central1"
# zone                    = "us-central1-b"
region = "us-east4"
zone   = "us-east4-c"
# region                  = "northamerica-northeast1"
# zone                    = "northamerica-northeast1-b"
# region                  = "us-east1"
# zone                    = "us-east1-c"
# region                  = "us-west1"
# zone                    = "us-west1-b"
# region                  = "us-west4"
# zone                    = "us-west4-b"
# region                  = "us-west2"
# zone                    = "us-west2-b"
# region                  = "southamerica-east1"
# zone                    = "southamerica-east1-c"