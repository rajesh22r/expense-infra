module "mysql_sg" {
  source                = "git::https://github.com/daws-81s/terraform-aws-security-group.git?ref=main"
  project_name          = var.project_name
  
  environment           = var.environment

  common_tags           = var.common_tags
  vpc_id = local.vpc_id
  sg_name = "mysql"
  sg_tags = var.mysql_sg_tags
}

module "node_sg" {
  source                = "git::https://github.com/daws-81s/terraform-aws-security-group.git?ref=main"
  project_name          = var.project_name
  
  environment           = var.environment

  common_tags           = var.common_tags
  vpc_id = local.vpc_id
  sg_name = "nodegroup"
  
}

module "control_plane_sg" {
  source                = "git::https://github.com/daws-81s/terraform-aws-security-group.git?ref=main"
  project_name          = var.project_name
  
  environment           = var.environment

  common_tags           = var.common_tags
  vpc_id = local.vpc_id
  sg_name = "controlplane"
  
}

module "ingress_alb_sg" {
  source                = "https://github.com/daws-81s/terraform-aws-security-group.git?ref=main"
  project_name          = var.project_name
  
  environment           = var.environment

  common_tags           = var.common_tags
  vpc_id = local.vpc_id
  sg_name = "ingressalb"
  
}






module "bastion_sg" {
  source                = "https://github.com/rajesh22r/terraform-aws-security-group.git?ref=main"
  project_name          = var.project_name
  
  environment           = var.environment

  common_tags           = var.common_tags
  vpc_id = local.vpc_id
  sg_name = "bastion"
  sg_tags = var.bastion_sg_tags
}







resource "aws_security_group_rule" "mysql_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id       = module.bastion_sg.id
  security_group_id = module.mysql_sg.id
}

resource "aws_security_group_rule" "control_plane_bastion" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  source_security_group_id       = module.bastion_sg.id
  security_group_id = module.control_plane_sg.id
}





resource "aws_security_group_rule" "bastion_public" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  
  security_group_id = module.bastion_sg.id
}

resource "aws_security_group_rule" "ingress_alb_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.ingress_alb_sg.id
}

resource "aws_security_group_rule" "node_ingress_alb" {
  type              = "ingress"
  from_port         = 30000
  to_port           = 32767
  protocol          = "tcp"
  source_security_group_id       = module.ingress_alb_sg.id
  security_group_id = module.node_sg.id
}

resource "aws_security_group_rule" "control_plane_node" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  source_security_group_id       = module.node_sg.id
  security_group_id = module.control_plane_sg.id
}

resource "aws_security_group_rule" "node_control_plane" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  source_security_group_id       = module.control_plane_sg.id
  security_group_id = module.node_sg.id
}

resource "aws_security_group_rule" "node_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          =  "tcp"
  source_security_group_id       = module.bastion_sg.id
  security_group_id = module.node_sg.id
}


resource "aws_security_group_rule" "node_vpc_cidr" {   #pod to pod or node to node taffic allowed 
                                                        #so everything from cidr is allowed
  type              = "ingress"  
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  
  security_group_id = module.node_sg.id
}

