# You cannot create a new backend by simply defining this and then
# immediately proceeding to "terraform apply". The S3 backend must
# be bootstrapped according to the simple yet essential procedure in
# https://github.com/cloudposse/terraform-aws-tfstate-backend#usage
# module "terraform_state_backend" {
#   source      = "cloudposse/tfstate-backend/aws"
#   version     = "1.5.0"
#   enabled     = false

#   profile     = local.profile

#   namespace  = module.label.namespace
#   name       = module.label.name
#   attributes = ["tfstate"]

#   terraform_backend_config_file_path = "."
#   terraform_backend_config_file_name = "backend.tf"
#   force_destroy                      = true
# }

provider "aws" {
  region  = local.region
}

# provider "aws" {
#   region = "us-east-1"
#   alias = "north-virginia"
# }

terraform {
  required_version = "~> 1.9.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.80.0"
    }
  }
}