module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace = local.namespace
  name      = local.name
}

data "aws_caller_identity" "current" {}

locals {
  profile    = var.profile
  region     = var.region
  identity   = data.aws_caller_identity.current
  account_id = local.identity.account_id
  name       = var.name
  namespace  = var.namespace
  app        = var.app != null ? var.app: "${local.name}-app"
  stages     = [
    "staging"
    , "prod"
  ]
  
  # prefixes
  ssm_prefix = "${"/"}${join("/", compact([
    module.label.namespace != "" ? module.label.namespace : null,
    module.label.name != "" ? module.label.name : null
  ]))}"
  pascal_prefix      = replace(title(module.label.id), "/\\W+/", "")
}

# NOTE: the lambda-runtime is just provisioning an ecr repository
# and few convinient outputs suitable to deploy a custom lamnda runtime image 
# so naming such as "bash" or "os" is purely for readability. 
# Also, you can alternatively deploy a single lambda runtime module and 
# differentiate between runtimes

module "lambda_bash_runtime" {
  source = "./modules/lambda-runtime"
  context = module.label.context
  attributes = ["bash"]
}

module "lambda_golang_runtime" {
  source = "./modules/lambda-runtime"
  context = module.label.context
  attributes = ["golang"]
}

resource "aws_api_gateway_rest_api" "api" {
  for_each = toset(local.stages)
  name     = "${local.app}-${each.key}"
}

