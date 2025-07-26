resource "aws_ssm_parameter" "router_credentials" {
  name     = "${local.ssm_prefix}/router/credentials"
  type     = "SecureString"
  value    = "-"

  lifecycle {
    ignore_changes = [ value ]
  }
}

resource "aws_ssm_parameter" "router_url" {
  name     = "${local.ssm_prefix}/router/url"
  type     = "String"
  value    = "-"

  lifecycle {
    ignore_changes = [ value ]
  }
}