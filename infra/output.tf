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
        rest_api_keys = {
            for stage in local.stages : stage => aws_ssm_parameter.rest_api_key[stage].name
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

# output "api_keys" {
#   sensitive = true
#   value = {
#     for stage in local.stages : stage => {
#       name  = aws_api_gateway_usage_plan_key.default[stage].name
#       value = aws_api_gateway_usage_plan_key.default[stage].value
#     }
#   }
# }

output "rest_api" {
  sensitive = true
  value = {
    for stage in local.stages : stage => 
      {
        url = "https://${aws_api_gateway_rest_api.api[stage].id}.execute-api.${local.region}.amazonaws.com/${stage}"
        key = aws_api_gateway_usage_plan_key.default[stage].value

      }
    
  }
}