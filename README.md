# development environment

This folder contains [infrastructure as code][IaC] (IaC) for a minimal development environment that supports swapping backend machines and associated GPU(s) to meet the demands of a given development task. It currently uses [terraform][terraform] with the [google cloud platform][gcpsdk] provider and the [google notebooks instance][gni] resource, but it could be adapted for other cloud platforms, providers, or resources (see the [terraform documentation][tfmdocs] for further reference).

## workflow
The expected workflow is to

- set up a development machine with `make up`, 
- connect to the machine via the associated jupyter lab server accessible from the [google cloud platform user interface][gcpui] for interactive use, 
- [ssh](#remote-connection) to the machine from a terminal or IDE such as [VS Code][vscodessh] for library development,
- toggle the machine off and on with `make stop` and `make start`, and
- destroy all associated resources with `make down`.

## prerequisites

- install [google cloud sdk][gcpsdk]
  - `gcloud init` to set project and [application default credentials][adc]
    - `gcloud auth login`
    - `gcloud auth application-default login`
- install [terraform][terraform]
  - `terraform init`
- set environment variables
  - [tfvars.sh](./tfvars.sh) is provided to help construct a `.env` file that is read by the [Makefile](.Makefile) to set environment variables. If you do not want to use [tfvars.sh](./tfvars.sh), you can create a `.env` file as informally described, for example, in [dotenv][python-dotenv] containing all variables written to `.env` at the end of [tfvars.sh](./tfvars.sh) and remove reference to [tfvars.sh](./tfvars.sh) in the [Makefile](./Makefile)
    - example `.env` file
      ```shell
      TF_VAR_project=<GCP Project ID> # your google cloud platform project ID
      TF_VAR_email=<GCP account email address> # your google cloud platform account email address
      TF_VAR_credentials_file=~/.config/gcloud/application_default_credentials.json # local path to your application default credentials
      TF_VAR_notebooks_name=pyrovelocity-dev-notebook # name to assign to your development virtual machine
      TF_VAR_post_startup_script_url=https://gist.githubusercontent.com/githubusername/b6c8cd158b00f99d21511a905cc7626a/raw/post-startup-script-dev-notebook.sh # publicly accessible URL to a startup script
      GITHUB_ORG_NAME=pinellolab # name the github or user containing the github repository with code for development
      GITHUB_REPO_NAME=pyrovelocity # name of a github repository with a conda environment yaml file
      GITHUB_BRANCH_NAME=master # name of github repository branch to checkout
      GITHUB_REPO_CONDA_ENV_PATH_NAME=conda/environment-gpu.yml # path to conda environment yaml file in the github repository
      STARTUP_SCRIPT_GITHUB_GIST_ID=b6c8cd158b00f99d21511a905cc7626a # the github gist ID if you would like to use a github gist
      ```
  - edit [tfvars.sh](./tfvars.sh)
    - this script is executed by default at the top level of the [Makefile](./Makefile) to set variables and upload `post-startup-script.sh` to a publicly accessible location for consumption by the virtual machine. A copy of the latter will be downloaded to and executed from the path `/opt/c2d/post_start.sh` on the remote machine.
    - set variables using [pass][pass] or manually
      - execute `pass insert github_username`
      - complete the same process for `gcp_credentials_file`, `gcp_email`, `gcp_project`, `gcp_notebooks_name`, `github_org`, `github_repo`, `github_branch`, and `github_repo_conda_env_path`
      - `gcp_credentials_file` contains the path to appication default credentials. The most common value is `~/.config/gcloud/application_default_credentials.json`
      - check these are all defined with `$ pass`

        ```shell
        $ pass
        Password Store
        ├── gcp_credentials_file
        ├── gcp_email
        ├── gcp_project
        ├── gcp_notebooks_name
        ├── github_org
        ├── github_repo
        ├── github_branch
        ├── github_repo_conda_env_path
        └── github_username
        ```

  - install and authenticate with [github cli][ghcli] to use gists for the post startup script
    - check `gh auth status` when complete
  - edit [template-post-startup-script.sh](./template-post-startup-script.sh)
    - execution of [tfvars.sh](./tfvars.sh) will upload your current local copy of `post-startup-script.sh` automatically generated from [template-post-startup-script.sh](./template-post-startup-script.sh) to a github gist by default
  - review/edit [terraform.tfvars](./terraform.tfvars)
    - you can optionally set parameters not currently read from environment variables in this file
    - for example, you may want to set the machine type, accelerator/GPU type, disk size, etc 
- when the requirements above are satisfied, `make test` will do the following
  - upload `post-startup-script.sh` to github gist
  - print `TF_VAR*` and `GITHUB*` environment variables

## usage 

The primary interface is via the [Makefile](./Makefile), which is being used here as a modular collection of short shell scripts rather than as a build system. You can fill environment variables and print each command prior to running with `make -n <target>` such as `make -n up`. Please see [GNU make][make] for further reference. The primary targets are

    make up - create -OR- update the instance
    make stop - stop the instance
    make start - start the instance
    make down - delete the instance
    
All other targets are auxiliary. The [Makefile](./Makefile) is primarily to document commands that are commonly used to work with the terraform resource(s). You can simply copy the command from the Makefile and run it manually in the terminal if you do not want to use [make][make].

## machine images

Check available machine images from the [deeplearning-platform-release](https://gcr.io/deeplearning-platform-release) by running `make show-disk-images`. You can modify the machine image by setting `vm_image_project` and `vm_image_family` in [terraform.tfvars](./terraform.tfvars). You can alternatively use a docker image by reviewing and editing the content of [notebooks-instance.tf](./notebooks-instance.tf) to use `container_image` instead of `vm_image`. You can also run `make show-container-images` to list available images. Note however that using a container image as opposed to a disk image would require a different post-startup configuration process. This can be incorporated into a [derivative container image][dci].

## remote connection

The [Makefile](./Makefile) will run

```shell
gcloud compute config-ssh
```

to update your ssh configuration file and print the configured hostname at the end of `make up`. In order to connect from IDEs or otherwise, it may be helpful to update your `~/.ssh/config` file with something similar to (updated to reference the key files you use with google cloud platform)

```shell
Host gcp
    HostName <IP_ADDRESS>
    IdentityFile ~/.ssh/google_compute_engine
    UserKnownHostsFile=~/.ssh/google_compute_known_hosts
    IdentitiesOnly=yes
    CheckHostIP=no
    StrictHostKeyChecking=no
    RequestTTY Yes
    RemoteCommand cd /home/jupyter && sudo su jupyter
```

The `IP_ADDRESS` of the remote host is printed at the end of `make up`. You can run `gcloud compute instances list` to display the `IP_ADDRESS` of the virtual machine if you need to reference it.
If you use the container rather than disk image to setup the virtual machine, you may find an alternative `RemoteCommand` useful

```shell
Host gcp
    ...
    RemoteCommand sudo docker exec -it payload-container /bin/bash
```


[IaC]: https://en.wikipedia.org/wiki/Infrastructure_as_code
[terraform]: https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/install-cli
[gcpsdk]: https://cloud.google.com/sdk/docs/install
[gni]: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/notebooks_instance
[tfmdocs]: https://developer.hashicorp.com/terraform/docs
[gcpui]: https://console.cloud.google.com/vertex-ai/workbench/list/instances
[vscodessh]: https://code.visualstudio.com/docs/remote/ssh
[adc]: https://cloud.google.com/docs/authentication/provide-credentials-adc
[python-dotenv]: https://github.com/theskumar/python-dotenv#file-format
[ghcli]: https://cli.github.com
[pass]: https://www.passwordstore.org/
[make]: https://www.gnu.org/software/make/
[dci]: https://cloud.google.com/deep-learning-containers/docs/derivative-container
