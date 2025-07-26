module "label" {
  source    = "cloudposse/label/null"
  version   = "0.25.0"
  context   = var.context 
  attributes = concat(["lambda-runtime"], var.attributes)
  
}

locals {
  deploy_tag = var.deploy_tag

  ssm_prefix = join("/", concat([
      "",
      "${module.label.namespace}",
      "${module.label.name}",
  ], "${module.label.attributes}"))
}

module "ecr" {
  source               = "cloudposse/ecr/aws"
  version              = "0.42.1"
  name                 = module.label.id
  tags                 = module.label.tags
  use_fullname         = false
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}
