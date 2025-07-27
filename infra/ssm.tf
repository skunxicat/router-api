resource "aws_ssm_parameter" "account_id" {
  name = "${local.ssm_prefix}/AWSAccountID"
  type  = "String"
  value = data.aws_caller_identity.current.account_id
}

## App indentifier (sync serverless project)
resource "aws_ssm_parameter" "app" {
  name = "${local.ssm_prefix}/app"
  type  = "String"
  value = local.app
}


resource "aws_ssm_parameter" "rest_api_id" {
  for_each = toset(local.stages)
  name     = "${local.ssm_prefix}/${each.key}/restApiId"
  type     = "String"
  value    = aws_api_gateway_rest_api.api[each.key].id
}

resource "aws_ssm_parameter" "rest_api_root_resource_id" {
  for_each = toset(local.stages)
  name     = "${local.ssm_prefix}/${each.key}/restApiRootResourceId"
  type     = "String"
  value    = aws_api_gateway_rest_api.api[each.key].root_resource_id
}

resource "aws_ssm_parameter" "rest_api_key" {
  for_each = toset(local.stages)
  name     = "${local.ssm_prefix}/${each.key}/restApiKey"
  type     = "String"
  value    = aws_api_gateway_api_key.default[each.key].name
}