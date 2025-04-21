# Exonomy Terraform Setup

## Quick Start

```bash
terraform init
terraform plan -var-file="credentials.tfvars" -var-file="terraform.tfvars"
terraform apply -var-file="credentials.tfvars" -var-file="terraform.tfvars"
