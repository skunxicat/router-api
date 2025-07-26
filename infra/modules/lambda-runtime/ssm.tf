resource "aws_ssm_parameter" "image" {
  name  = "${local.ssm_prefix}/image"
  type  = "String"
  value = "${module.ecr.repository_url}:${local.deploy_tag}"
}