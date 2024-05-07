data "aws_caller_identity" "current" {}

module "lambda_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "7.4.0"

  function_name = "${var.name}-ami-refresh"
  description   = "Function to refresh ami id in Launch Template"
  handler       = "index.lambda_handler"
  runtime       = "python3.12"
  environment_variables = {
    LaunchTemplateId = aws_launch_template.template.id
    Owner            = data.aws_caller_identity.current.account_id
    ImagePrefix      = var.image_name_prefix
  }
  source_path = "./src/lambda_code_refresh"
  tags = merge(
    var.common_tags,
    {
      Name = "${var.name}-ami-refresh"
  })
}