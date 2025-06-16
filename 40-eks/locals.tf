locals {
  resource_name = "${var.project_name}-${var.environment}"
  node_sg_id = data.aws_ssm_parameter.node_sg_id.value
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  control_plane_sg_id = data.aws_ssm_parameter.control_plane_sg_id.value
  private_subnet_id = split(",", data.aws_ssm_parameter.private_subnet_ids.value)
}