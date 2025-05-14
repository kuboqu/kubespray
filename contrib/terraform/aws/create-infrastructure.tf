module "iam" {
  source           = "./modules/iam"
  aws_cluster_name = var.aws_cluster_name
}

module "vpc" {
  source           = "./modules/vpc"
  aws_cluster_name = var.aws_cluster_name
  vpc_cidr         = var.vpc_cidr
  public_subnets   = var.public_subnets
  private_subnets  = var.private_subnets
  db_subnets       = var.db_subnets
  ops_subnets      = var.ops_subnets
  azs              = var.azs
  environment      = var.environment
  default_tags     = var.default_tags

  ops_allowed_ingress = [
    { from_port = 0, to_port = 0, protocol = "-1", cidr = "0.0.0.0/0" },
    { from_port = 80, to_port = 80, protocol = "tcp", cidr = "0.0.0.0/0" },
    { from_port = 443, to_port = 443, protocol = "tcp", cidr = "0.0.0.0/0" },

    { from_port = 22, to_port = 22, protocol = "tcp", sg_source = module.vpc.bastion_sg }, # SSH Access from bastion
    { from_port = 0, to_port = 0, protocol = "-1", cidr = var.vpc_cidr },                  # k8s Access from fe_node
  ]

  db_allowed_ingress = [
    { from_port = 0, to_port = 0, protocol = "-1", cidr = "0.0.0.0/0" },
    { from_port = 22, to_port = 22, protocol = "tcp", sg_source = module.vpc.bastion_sg }, # SSH Access from bastion
    { from_port = 0, to_port = 0, protocol = "-1", cidr = var.vpc_cidr },                  # k8s Access from fe_node
  ]

  be_allowed_ingress = [
    { from_port = 0, to_port = 0, protocol = "-1", cidr = "0.0.0.0/0" },
    { from_port = 22, to_port = 22, protocol = "tcp", sg_source = module.vpc.bastion_sg }, # SSH Access from bastion
    { from_port = 0, to_port = 0, protocol = "-1", cidr = var.vpc_cidr },                  # k8s Access from fe_node
  ]

  fe_allowed_ingress = [
    { from_port = 0, to_port = 0, protocol = "-1", cidr = "0.0.0.0/0" },
    { from_port = 80, to_port = 80, protocol = "tcp", cidr = "0.0.0.0/0" },
    { from_port = 443, to_port = 443, protocol = "tcp", cidr = "0.0.0.0/0" },

    { from_port = 22, to_port = 22, protocol = "tcp", sg_source = module.vpc.bastion_sg }, # SSH Access from bastion
    { from_port = 0, to_port = 0, protocol = "-1", cidr = var.vpc_cidr },                  # k8s Access from be_node
  ]

  bastion_allowed_ingress = [
    { from_port = 22, to_port = 22, protocol = "tcp", cidr = "0.0.0.0/0" }, # SSH Access

    { from_port = 0, to_port = 0, protocol = "-1", cidr = "0.0.0.0/0" }, # Ansible Access
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

resource "aws_instance" "bastion_node" {
  ami                    = var.ami_id
  instance_type          = "t3.micro"
  subnet_id              = module.vpc.public_subnet_ids[0]
  key_name               = var.key_pair_name
  vpc_security_group_ids = [module.vpc.bastion_sg]

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y curl
              curl -fsSL https://tailscale.com/install.sh | sh
              tailscale up --authkey=${var.tailscale_auth_key} --hostname=kubernetes-${var.aws_cluster_name}-${var.environment}-bastion-node
              EOF

  tags = merge(var.default_tags, tomap({
    Name = "kubernetes-${var.aws_cluster_name}-bastion-node"
  }))
}

# Create Kubespray Inventory File
locals {
  inventory_rendered = templatefile("${path.module}/templates/inventory.tpl", {
    bastion_node_connection_string = format("%s ansible_host=%s", format("%s-%s-bastion_node", var.aws_cluster_name, var.environment), aws_instance.bastion_node.public_ip)
    ops_node_connection_string     = join("\n", [for idx, inst in aws_instance.ops_node : format("%s ansible_host=%s", inst.private_dns, inst.private_ip)])
    db_node_connection_string      = join("\n", [for idx, inst in aws_instance.db_node : format("%s ansible_host=%s", inst.private_dns, inst.private_ip)])
    be_node_connection_string      = join("\n", [for idx, inst in aws_instance.be_node : format("%s ansible_host=%s", inst.private_dns, inst.private_ip)])
    fe_node_connection_string      = join("\n", [for idx, inst in aws_instance.fe_node : format("%s ansible_host=%s", inst.private_dns, inst.private_ip)])

    bastion_node_list = format("%s", format("%s-%s-bastion_node", var.aws_cluster_name, var.environment))
    ops_node_list     = join("\n", [for idx, inst in aws_instance.ops_node : format("%s", inst.private_dns)])
    db_node_list      = join("\n", [for idx, inst in aws_instance.db_node : format("%s", inst.private_dns)])
    be_node_list      = join("\n", [for idx, inst in aws_instance.be_node : format("%s", inst.private_dns)])
    fe_node_list      = join("\n", [for idx, inst in aws_instance.fe_node : format("%s", inst.private_dns)])

    nlb_api_fqdn              = "apiserver_loadbalancer_domain_name=\"${module.nlb.nlb_api_fqdn}\""
    node_user                 = var.node_user
    ssh_private_key_file      = var.ssh_private_key_file
    ansible_local_release_dir = var.ansible_local_release_dir
  })
}

resource "null_resource" "inventories" {
  provisioner "local-exec" {
    command = <<EOT
cat <<EOF > ${var.inventory_file}
${local.inventory_rendered}
EOF
EOT
  }

  triggers = {
    template = sha256(local.inventory_rendered)
  }
}

