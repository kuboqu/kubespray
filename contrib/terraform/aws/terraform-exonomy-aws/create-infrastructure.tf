module "iam" {
  source           = "./modules/iam"
  aws_cluster_name = "exonomy"
}

module "vpc" {
  aws_cluster_name = var.aws_cluster_name
  source           = "./modules/vpc"
  vpc_cidr         = var.vpc_cidr
  public_subnets   = var.public_subnets
  private_subnets  = var.private_subnets
  db_subnets       = var.db_subnets
  ops_subnets      = var.ops_subnets
  azs              = var.azs
  environment      = var.environment
  default_tags     = var.default_tags

  ops_allowed_ingress = [
    { from_port = 51820, to_port = 51820, protocol = "udp", cidr = "0.0.0.0/0" }, # WireGuard VPN
    { from_port = 6443, to_port = 6443, protocol = "tcp", cidr = "0.0.0.0/0" }    # K8s API for admins via VPN
  ]

  db_allowed_ingress = [
    { from_port = 3306, to_port = 3306, protocol = "tcp", sg_source = module.vpc.be_sg }, # Allow backend to DB
    { from_port = 6379, to_port = 6379, protocol = "tcp", sg_source = module.vpc.be_sg }  # Allow backend to Redis
  ]

  be_allowed_ingress = [
    { from_port = 80, to_port = 80, protocol = "tcp", sg_source = module.vpc.fe_sg }, # Allow frontend to backend
  ]

  fe_allowed_ingress = [
    { from_port = 80, to_port = 80, protocol = "tcp", cidr = "0.0.0.0/0" },
    { from_port = 443, to_port = 443, protocol = "tcp", cidr = "0.0.0.0/0" }
  ]

}

module "nlb" {
  source              = "./modules/nlb"
  aws_cluster_name    = var.aws_cluster_name
  vpc_id              = module.vpc.vpc_id
  subnets             = module.vpc.public_subnet_ids
  aws_nlb_api_port    = var.aws_nlb_api_port
  k8s_secure_api_port = var.k8s_secure_api_port
  default_tags        = var.default_tags
}

resource "aws_instance" "ops_node" {
  count                  = 1 # TODO: Allow multiple resource instances
  ami                    = var.ami_id
  instance_type          = "m6a.large"
  subnet_id              = module.vpc.ops_subnet_ids[0]
  key_name               = var.key_pair_name
  vpc_security_group_ids = [module.vpc.ops_sg]
  iam_instance_profile   = module.iam.kube_control_plane-profile

  root_block_device {
    volume_size = var.fe_node_volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  tags = merge(var.default_tags, tomap({
    Name                                            = "kubernetes-${var.aws_cluster_name}-ops-node-${count.index}"
    "kubernetes.io/cluster/${var.aws_cluster_name}" = "member"
    Role                                            = "master"
  }))
}

resource "aws_lb_target_group_attachment" "tg-attach_master_nodes" {
  count            = 1 # TODO: Allow multiple resource instances
  target_group_arn = module.nlb.nlb_api_tg_arn
  target_id        = element(aws_instance.ops_node.*.private_ip, count.index)
}

resource "aws_instance" "db_node" {
  count                  = 1 # TODO: Allow multiple resource instances
  ami                    = var.ami_id
  instance_type          = "r6i.large"
  subnet_id              = module.vpc.db_subnet_ids[0]
  key_name               = var.key_pair_name
  vpc_security_group_ids = [module.vpc.db_sg]
  iam_instance_profile   = module.iam.kube-worker-profile

  root_block_device {
    volume_size = var.db_node_volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  tags = merge(var.default_tags, tomap({
    Name                                            = "kubernetes-${var.aws_cluster_name}-db-done-${count.index}"
    "kubernetes.io/cluster/${var.aws_cluster_name}" = "member"
    Role                                            = "worker"
  }))
}

resource "aws_instance" "be_node" {
  count                  = 1 # TODO: Allow multiple resource instances
  ami                    = var.ami_id
  instance_type          = "m5.large"
  subnet_id              = module.vpc.private_subnet_ids[0]
  key_name               = var.key_pair_name
  vpc_security_group_ids = [module.vpc.be_sg]
  iam_instance_profile   = module.iam.kube-worker-profile

  root_block_device {
    volume_size = var.be_node_volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  tags = merge(var.default_tags, tomap({
    Name                                            = "kubernetes-${var.aws_cluster_name}-be-node-${count.index}"
    "kubernetes.io/cluster/${var.aws_cluster_name}" = "member"
    Role                                            = "worker"
  }))
}

resource "aws_instance" "fe_node" {
  count                  = 1 # TODO: Allow multiple resource instances
  ami                    = var.ami_id
  instance_type          = "m5.large"
  subnet_id              = module.vpc.public_subnet_ids[0]
  key_name               = var.key_pair_name
  vpc_security_group_ids = [module.vpc.fe_sg]
  iam_instance_profile   = module.iam.kube-worker-profile

  root_block_device {
    volume_size = var.fe_node_volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  tags = merge(var.default_tags, tomap({
    Name                                            = "kubernetes-${var.aws_cluster_name}-fe-node-${count.index}"
    "kubernetes.io/cluster/${var.aws_cluster_name}" = "member"
    Role                                            = "worker"
  }))
}
