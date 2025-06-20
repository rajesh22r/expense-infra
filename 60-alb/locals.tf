locals {
  resource_name = "${var.project_name}-${var.environment}"
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  public_subnet_id = split(",", data.aws_ssm_parameter.public_subnet_ids.value)
  aws_acm_certificate_arn = data.aws_ssm_parameter.aws_acm_certificate_arn.value
}
