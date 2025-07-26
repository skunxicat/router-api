output "ecr" {
    value = module.ecr
}

output "image" {
    sensitive = true
    value =  {
        name        = "${module.ecr.repository_url}:${local.deploy_tag}"
        arn         = "${module.ecr.repository_arn}:${local.deploy_tag}"
        ssm_name    = "${aws_ssm_parameter.image.name}"
    }
}