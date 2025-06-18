resource "aws_key_pair" "eks" {
  key_name   = "eks"
  # you can paste the public key directly like this
  #public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL6ONJth+DzeXbU3oGATxjVmoRjPepdl7sBuPzzQT2Nc sivak@BOOK-I6CR3LQ85Q"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDYZT/M4wJAr9HarlDaGAcV6nsZhP3ED+DfsQH5gXEcKlI+Xq5A/ycPg0djJs46sMKckhqW3D6LYTmtDdODVhjsVO05IbTFMqbPWDTBf5hsY7isW1sYrrKC+sBKS+y2UPfdtMXBUjLP4tuZI9l2qTNaio6N6XmM8cdnm8bhQrP0WcoasG5VbAMIZv1PbbYNWO92/csivIfwxGswqTpLPKcRfzu9rFOrhOHqMfHoBis61SE+1EHkXHO2nNnKear49Qt7XJFS/ignE21E5CCHVvW5eeEl5zhhvWd1r+IPDqRylT6Fkf6Oynk2z/GV+A98/bLuNqj6P8RELDw7VnwGPN/96E6FEjUlwEcgCJSy04IkdN1O+B1fx24C+q4YdnKefjpZ19lKExvW5wMElt/8bzXBXkxZzzvXO/6G0MUbsGPW/ouMrh8sBUEJdblNCEFjTGQEM/8iF1lgShrAz3IxHYd4jPnFRp1NTX2/deQAca3yFmPkRR88dQ8cngAMTwRqpQgdpI4/bePXwThP6ndYattiZ2Otyx0p4nKzlXyucKvka1Xga5wCQ3LSfAGhri4vVo3oGxXG30EfOW35qrEOgZ5HB3phpoeqfNhV/0BK19KrbEqiR41Oa3PQx7MTsBjruESzMUr0fQVBGUKElz8n1C5jxyknGdMa1dQW4S+Jtc3bOw== HP@DESKTOP-1L5IA5E"


  # ~ means windows home directory
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"


  cluster_name    = "${var.project_name}-${var.environment}"
  cluster_version = "1.31"

  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  vpc_id                   = data.aws_ssm_parameter.vpc_id.value
  subnet_ids               = local.private_subnet_id
  control_plane_subnet_ids = local.private_subnet_id

  create_cluster_security_group = false
  cluster_security_group_id     = local.control_plane_sg_id

  create_node_security_group = false
  node_security_group_id     = local.node_sg_id

  # the user which you used to create cluster will get admin access

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    # blue = {
    #   min_size      = 2
    #   max_size      = 10
    #   desired_size  = 2
    #   #capacity_type = "SPOT"
    #   iam_role_additional_policies = {
    #     AmazonEBSCSIDriverPolicy          = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    #     AmazonElasticFileSystemFullAccess = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
    #     ElasticLoadBalancingFullAccess = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
    #   }
    #   # EKS takes AWS Linux 2 as it's OS to the nodes
    #   key_name = aws_key_pair.eks.key_name
    # }

    green = {
      min_size      = 2
      max_size      = 10
      desired_size  = 2
      #capacity_type = "SPOT"
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy          = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        AmazonElasticFileSystemFullAccess = "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"
        ElasticLoadBalancingFullAccess = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
      }
      # EKS takes AWS Linux 2 as it's OS to the nodes
      key_name = aws_key_pair.eks.key_name
    }
  }

  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  tags = var.common_tags
}