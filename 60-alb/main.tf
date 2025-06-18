module "ingress_alb" {
  source = "terraform-aws-modules/alb/aws"

  name    = "${local.resource_name}-ingress-alb"
  vpc_id  = local.vpc_id
  internal = true
  subnets = local.public_subnet_id
  security_groups = [data.aws_ssm_parameter.ingress_alb_sg_id.value]
  enable_deletion_protection = false
  create_security_group = false
  tags = merge(

       var.common_tags,
        )
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = module.ingress_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "Hello I am from ingress Application ALB"
      status_code  = "200"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = module.ingress_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = local.aws_acm_certificate_arn
  

   default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1>Hello, I am from Web ALB HTTPS</h1>"
      status_code  = "200"
    }
  }
}



module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  

  zone_name = var.zone_name

  records = [
    {
      name    = "expense-${var.environment}"
      type    = "A"
      allow_overwrite = true
      alias   = {
        name    = module.ingress_alb.dns_name
        zone_id = module.ingress_alb.zone_id
      }
    }
    
  ]
}


resource "aws_lb_target_group" "expense" {
  name     = local.resource_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = local.vpc_id
  target_type = "ip"

health_check {
  healthy_threshold = 2
  interval = 5
  matcher = "200-299"
  path = "/health"
  port = 80
  protocol = "HTTP"
  timeout = 4
  unhealthy_threshold = 2
}
}


resource "aws_lb_listener_rule" "frontend" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.expense.arn
  }

  

  condition {
    host_header {
      values = ["expense-${var.environment}.${var.zone_name}"]
    }
  }
}

