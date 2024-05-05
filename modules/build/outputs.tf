output "instance_security_group_id" {
  value = aws_security_group.instance_build_sg.id
}

output "aws_ssm_parameter_cloudwatch_config" {
  value = aws_ssm_parameter.cloudwatch.name
}