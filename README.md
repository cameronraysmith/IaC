# development environment

This documents infrastructure as code (IaC) for a minimal development environment that supports swapping backend machines and associated GPU(s) to meet the demands of a given development task. It currently uses [terraform][terraform] with the [google cloud platform][gcpsdk] provider, but it could be adapted for other cloud platforms or providers (see the [terraform documentation][tfmdocs] for further reference).

The general workflow is to set up a development machine with `make up`, connect to the machine via the associated jupyter lab server accessible from the google cloud platform user interface for interactive use, and ssh to the machine from a terminal or IDE such as VS Code for library development. The machine can be toggled off and on with `make stop` and `make start`. All associated resources can be destroyed with `make down`.

## prerequisites

- install [google cloud sdk][gcpsdk]
  - `gcloud init` to set project
    - `gcloud auth login`
    - `gcloud auth application-default login`
- install [terraform][terraform]
  - `terraform init`
- edit [tfvars.sh](./tfvars.sh)
  - set variables using [pass][pass] or manually
  - install and authenticate with [github cli][ghcli] to use gists for the post startup script
    - check `gh auth status` when complete
  - executing this script will upload [post-startup-script.sh](./post-startup-script.sh) to github gist by default
- review/edit [terraform.tfvars](./terraform.tfvars)
  - you can optionally set the post startup script url here if you are not able to set up the [github cli][ghcli] 
- `make test` will function when above are satisfied
  - upload [post-startup-script.sh](./post-startup-script.sh) to github gist
  - print `TF_VARS_*` environment variables

## usage 

The primary interface is via the [Makefile](./Makefile), which is being used here as a modular collection of short shell scripts rather than as a build system. You can fill environment variables and print each command prior to running with `make -n <target>` such as `make -n up`. Please see [GNU make][make] for further reference. The primary targets are

    make up - create -OR- update the instance
    make stop - stop the instance
    make start - start the instance
    make down - delete the instance
    
All other targets are auxiliary. The [Makefile](./Makefile) is primarily to document commands that are commonly used to work with the terraform resource(s). You can simply copy the command from the Makefile and run it manually in the terminal if you do not want to use [make][make].

[make]: https://www.gnu.org/software/make/
[gcpsdk]: https://cloud.google.com/sdk/docs/install
[tfmdocs]: https://developer.hashicorp.com/terraform/docs
[terraform]: https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/install-cli
[pass]: https://www.passwordstore.org/
[ghcli]: https://cli.github.com
