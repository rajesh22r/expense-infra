locals {
    resource_name = "${var.project_name}-${var.environment}"
    aws_acm_certificate_arn = data.aws_ssm_parameter.aws_acm_certificate_arn.value
}