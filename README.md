# infrastructure as code

This repository contains [infrastructure as code][IaC] (IaC) for environments associated to scientific computing. It currently uses [terraform][terraform] (see the [terraform documentation][tfmdocs] for further reference). Other [IaC][IaC] tools such as [pulumi][pulumi] may also be included in the future. 

## development environments

### terraform

#### gcp

##### notebooks

- [GPU-enabled development environment on GCP Vertex AI notebooks](./dev/terraform/gcp/notebooks/)

[IaC]: https://en.wikipedia.org/wiki/Infrastructure_as_code
[terraform]: https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/install-cli
[tfmdocs]: https://developer.hashicorp.com/terraform/docs
[pulumi]: https://www.pulumi.com/
