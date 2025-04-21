module "vpc" {
  source  = "../../modules/networking"
  cidr    = var.vpc_cidr
  subnets = var.public_subnets
}

module "security_groups" {
  source      = "../../modules/security_groups"
  vpc_id      = module.vpc.vpc_id
  environment = "dev"
}

module "operations_node" {
  source              = "../../modules/ec2_instance"
  ami_id              = var.ami_id
  instance_type       = "m6a.large"
  subnet_id           = module.vpc.public_subnets[0]
  key_pair_name       = var.key_pair_name
  security_group_ids  = [module.security_groups.ops_sg_id]
  instance_name       = "dev-ops-control-node"
  environment         = "dev"
  role                = "operations"
}

module "database_node" {
  source              = "../../modules/ec2_instance"
  ami_id              = var.ami_id
  instance_type       = "r6i.large"
  subnet_id           = module.vpc.public_subnets[0]
  key_pair_name       = var.key_pair_name
  security_group_ids  = [module.security_groups.db_sg_id]
  instance_name       = "dev-database-node"
  environment         = "dev"
  role                = "database"
}

module "workload_nodes" {
  source              = "../../modules/ec2_instance"
  count               = 2
  ami_id              = var.ami_id
  instance_type       = "m5.large"
  subnet_id           = module.vpc.public_subnets[1]
  key_pair_name       = var.key_pair_name
  security_group_ids  = [module.security_groups.workload_sg_id]
  instance_name       = "dev-workload-node-${count.index+1}"
  environment         = "dev"
  role                = "workload"
}
