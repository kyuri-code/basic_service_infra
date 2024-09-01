# SSM Parameter for db_name
resource "aws_ssm_parameter" "db_name" {
  name  = "/myapp/db_name"
  type  = "String"
  value = "sample"

  tags = merge(
    var.common_tags,
    { "Name" = "${local.project_prefix}-db-name" }
  )
}

# SSM Parameter for username
resource "aws_ssm_parameter" "db_username" {
  name  = "/myapp/db_username"
  type  = "String"
  value = "user123"

  tags = merge(
    var.common_tags,
    { "Name" = "${local.project_prefix}-db-username" }
  )
}

# SSM Parameter for password
resource "aws_ssm_parameter" "db_password" {
  name  = "/myapp/db_password"
  type  = "SecureString"
  value = "Password!23"

  tags = merge(
    var.common_tags,
    { "Name" = "${local.project_prefix}-db-password" }
  )
}