data "aws_cloudfront_cache_policy" "noCache" {
  name = "Managed-CachingDisabled"
}

data "aws_cloudfront_cache_policy" "cacheOptmised" {
  name = "Managed-CachingOptimized"
}

data "aws_ssm_parameter" "aws_acm_certificate_arn" {
  name = "/${var.project_name}/${var.environment}/aws_acm_certificate_arn"
}