# POLITO IS CLOUD 2021

## LAB 01

## Prerequisites

- Terraform 0.15 or greater
- AWS CLI installed
- AWS Account
- saml2aws for federated AWS access
- GNU Make toolchain

## Instructions

There is a Makefile that helps deploying the infrastructure.

1. **make init** initializes federated access to the AWS Account to set credentials. You can skip this if you have static credentials
2. **make init-backend** initializes terraform backend for the main terraform module
3. **make init-main** initializes main module
4. **make plan** plans the execution and saves plan file to tmp folder
5. **make apply** applies saved plan
 
## Next steps

1. Add SSL and custom domain names to the solution
1. Configure Memcached in Wordpress solution

## CAVEATS

- S3 bucket names must be unique across all s3 customers. Unique identifiers are hard-coded in this configuration:
    - terraform-init-backend/main.tf -> bucket resource name must be changed
    - terraform/02-data-layer.tf -> bucket resource for alb logs name and bucket policy must be changed
- Code is intended to be run in eu-west-1 region. In case you want to change region you must:
    - Change region in provider configuration
    - terraform/02-data-layer.tf -> bucket resource for alb logs bucket policy must be changed according to AWS documentation for Log delivery
- Given the fact that the installation script provided by the original [training workshop](https://ha-webapp.workshop.aws/) is not working anymore, we replaced it with a docker based version for simplicity.


## Explanation of the solution

This is a Terraform 0.15 implementation of the architecture described in this [training workshop](https://ha-webapp.workshop.aws/). A Makefile orchestrates terraform commands to create, update, destroy all infrastructure.


Login to your AWS Account through federation -- You can skip it if in Cloud9 or you configured your AWS cli for static credentials
```bash
make init
```

Initializes AWS resources in the account used by the main terraform module to handle concurrency and state persistance. It implements design available here: https://www.terraform.io/docs/language/settings/backends/s3.html

```bash
make init-backend
```
Initializes main terraform module by downloading dependencies and initializing the backend

```bash
make init-main
```

Triggers a plan phase with output saved to stage directory. Plan is then applied. This is the step that actually creates solution resources. In the output 

```bash
make apply
```

Destroy backend resources

```bash
make destroy-main
```

Destroy created resources from main module

```bash
make destroy-backend
```
 
# Author

Federico BARBERO - [f.barbero@reply.it](mailto:f.barbero@reply.it)