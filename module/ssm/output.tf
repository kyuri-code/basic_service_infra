output "db_name" {
  value = aws_ssm_parameter.db_name.value
}

output "db_username" {
  value = aws_ssm_parameter.db_username.value
}

output "db_password" {
  value = aws_ssm_parameter.db_password.value
}