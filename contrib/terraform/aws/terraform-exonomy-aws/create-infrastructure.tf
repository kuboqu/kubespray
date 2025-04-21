module "vpc" {
  source        = "./modules/vpc"
  vpc_cidr      = var.vpc_cidr
  public_subnets = var.public_subnets
  azs           = var.azs
  environment   = var.environment
}

module "nlb" {
  source      = "./modules/nlb"
  subnets     = module.vpc.public_subnet_ids
  environment = var.environment
}

resource "aws_instance" "ops_node" {
  ami                    = var.ami_id
  instance_type          = "m6a.large"
  subnet_id              = module.vpc.public_subnet_ids[0]
  key_name               = var.key_pair_name
  vpc_security_group_ids = [module.vpc.default_sg]

  tags = { Name = "${var.environment}-ops-node" }
}

resource "aws_instance" "db_node" {
  ami                    = var.ami_id
  instance_type          = "r6i.large"
  subnet_id              = module.vpc.public_subnet_ids[0]
  key_name               = var.key_pair_name
  vpc_security_group_ids = [module.vpc.default_sg]

  tags = { Name = "${var.environment}-db-node" }
}

resource "aws_instance" "workload_nodes" {
  count                  = 2
  ami                    = var.ami_id
  instance_type          = "m5.large"
  subnet_id              = module.vpc.public_subnet_ids[1]
  key_name               = var.key_pair_name
  vpc_security_group_ids = [module.vpc.default_sg]

  tags = { Name = "${var.environment}-workload-node-${count.index+1}" }
}
