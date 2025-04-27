module "vpc" {
  source          = "./modules/vpc"
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  db_subnets      = var.db_subnets
  ops_subnets     = var.ops_subnets
  azs             = var.azs
  environment     = var.environment

  fe_allowed_ingress = [
    { from_port = 80, to_port = 80, protocol = "tcp", cidr = "0.0.0.0/0" },
    { from_port = 443, to_port = 443, protocol = "tcp", cidr = "0.0.0.0/0" }
  ]

  be_allowed_ingress = [
    { from_port = 80, to_port = 80, protocol = "tcp", sg_source = module.vpc.fe_sg },      # Allow frontend to backend
  ]

  db_allowed_ingress = [
    { from_port = 3306, to_port = 3306, protocol = "tcp", sg_source = module.vpc.be_sg }, # Allow backend to DB
    { from_port = 6379, to_port = 6379, protocol = "tcp", sg_source = module.vpc.be_sg }  # Allow backend to Redis
  ]

  ops_allowed_ingress = [
    { from_port = 51820, to_port = 51820, protocol = "udp", cidr = "0.0.0.0/0" },          # WireGuard VPN
    # { from_port = 6443, to_port = 6443, protocol = "tcp", sg_source = "sg-vpn-client-id" } # K8s API for admins via VPN
  ]
}

module "nlb" {
  source      = "./modules/nlb"
  subnets     = module.vpc.public_subnet_ids
  environment = var.environment
}

resource "aws_instance" "fe_node" {
  ami                    = var.ami_id
  instance_type          = "m5.large"
  subnet_id              = module.vpc.public_subnet_ids[0]
  key_name               = var.key_pair_name
  vpc_security_group_ids = [module.vpc.fe_sg]

  tags = { Name = "${var.environment}-fe-node" }
}

resource "aws_instance" "be_node" {
  ami                    = var.ami_id
  instance_type          = "m5.large"
  subnet_id              = module.vpc.private_subnet_ids[0]
  key_name               = var.key_pair_name
  vpc_security_group_ids = [module.vpc.be_sg]

  tags = { Name = "${var.environment}-be-node" }
}

resource "aws_instance" "db_node" {
  ami                    = var.ami_id
  instance_type          = "r6i.large"
  subnet_id              = module.vpc.db_subnet_ids[0]
  key_name               = var.key_pair_name
  vpc_security_group_ids = [module.vpc.db_sg]

  tags = { Name = "${var.environment}-db-node" }
}

resource "aws_instance" "ops_node" {
  ami                    = var.ami_id
  instance_type          = "m6a.large"
  subnet_id              = module.vpc.ops_subnet_ids[0]
  key_name               = var.key_pair_name
  vpc_security_group_ids = [module.vpc.ops_sg]

  tags = { Name = "${var.environment}-ops-node" }
}
