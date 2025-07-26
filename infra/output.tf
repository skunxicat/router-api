output id {
    value = {
        name = module.label.name
        namespace = module.label.namespace
        id = module.label.id
    }
}

output lambda_runtime {
    value = {
        bash    = module.lambda_bash_runtime
        golang  = module.lambda_golang_runtime
    }
}


output ssm {
    value = {
        prefix                          = local.ssm_prefix
        app                             = aws_ssm_parameter.app.name
        rest_api_ids = {
          for stage in local.stages : stage => aws_ssm_parameter.rest_api_id[stage].name
        }
        rest_api_root_resource_ids = {
          for stage in local.stages : stage => aws_ssm_parameter.rest_api_root_resource_id[stage].name
        }
        
    }
}

output router {
    sensitive = true
    value = {
        ssm_credential_param = aws_ssm_parameter.router_credentials.name
        ssm_url_param = aws_ssm_parameter.router_url
    }
}