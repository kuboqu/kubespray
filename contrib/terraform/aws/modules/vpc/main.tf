# VPC and IGW
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.default_tags, tomap({
    Name = "kubernetes-${var.aws_cluster_name}-vpc"
  }))
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.default_tags, tomap({
    Name = "kubernetes-${var.aws_cluster_name}-internetgw"
  }))
}
########################################################################

# Subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnets, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true

  tags = merge(var.default_tags, tomap({
    Name                                            = "kubernetes-${var.aws_cluster_name}-${element(var.azs, count.index)}-public"
    "kubernetes.io/cluster/${var.aws_cluster_name}" = "shared"
    "kubernetes.io/role/elb"                        = "1"
  }))
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnets, count.index)
  availability_zone = element(var.azs, count.index)

  tags = merge(var.default_tags, tomap({
    Name                                            = "kubernetes-${var.aws_cluster_name}-${element(var.azs, count.index)}-private"
    "kubernetes.io/cluster/${var.aws_cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"               = "1"
  }))
}

resource "aws_subnet" "db" {
  count             = length(var.db_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.db_subnets, count.index)
  availability_zone = element(var.azs, count.index)

  tags = merge(var.default_tags, tomap({
    Name                                            = "kubernetes-${var.aws_cluster_name}-${element(var.azs, count.index)}-db"
    "kubernetes.io/cluster/${var.aws_cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"               = "1"
  }))
}

resource "aws_subnet" "ops" {
  count             = length(var.ops_subnets)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.ops_subnets, count.index)
  availability_zone = element(var.azs, count.index)

  tags = merge(var.default_tags, tomap({
    Name                                            = "kubernetes-${var.aws_cluster_name}-${element(var.azs, count.index)}-ops"
    "kubernetes.io/cluster/${var.aws_cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"               = "1"
  }))
}
########################################################################

# NAT Gateway and Elastic IP
resource "aws_eip" "nat" {
  # Removed the deprecated `vpc` argument
  # vpc = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(var.default_tags, tomap({
    Name = "kubernetes-${var.aws_cluster_name}-nat-gateway"
  }))
}
########################################################################

# Routing Tables
# Public Route Table
resource "aws_route_table" "public" {
  count  = 1 # TODO: Allow multiple resource instances
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(var.default_tags, tomap({
    Name = "kubernetes-${var.aws_cluster_name}-routetable-public"
  }))
}

# Private, DB, OPS Route Tables (with NAT)
resource "aws_route_table" "private" {
  count  = 1 # TODO: Allow multiple resource instances
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = merge(var.default_tags, tomap({
    Name = "kubernetes-${var.aws_cluster_name}-routetable-private-${count.index}"
  }))
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[count.index % length(aws_route_table.public)].id
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index % length(aws_route_table.private)].id
}

resource "aws_route_table_association" "db" {
  count          = length(aws_subnet.db)
  subnet_id      = aws_subnet.db[count.index].id
  route_table_id = aws_route_table.private[count.index % length(aws_route_table.private)].id
}

resource "aws_route_table_association" "ops" {
  count          = length(aws_subnet.ops)
  subnet_id      = aws_subnet.ops[count.index].id
  route_table_id = aws_route_table.private[count.index % length(aws_route_table.private)].id
}
########################################################################

# Security Groups
# Bastion
resource "aws_security_group" "bastion_sg" {
  name   = "kubernetes-${var.aws_cluster_name}-bastion-sg"
  vpc_id = aws_vpc.main.id

  dynamic "ingress" {
    for_each = var.bastion_allowed_ingress
    content {
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      cidr_blocks     = ingress.value.cidr != null ? [ingress.value.cidr] : null
      security_groups = ingress.value.sg_source != null ? [ingress.value.sg_source] : null
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.default_tags, tomap({
    Name = "kubernetes-${var.aws_cluster_name}-bastion-sg"
  }))
}

# Frontend
resource "aws_security_group" "fe_sg" {
  name   = "kubernetes-${var.aws_cluster_name}-fe-sg"
  vpc_id = aws_vpc.main.id

  dynamic "ingress" {
    for_each = var.fe_allowed_ingress
    content {
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      cidr_blocks     = ingress.value.cidr != null ? [ingress.value.cidr] : null
      security_groups = ingress.value.sg_source != null ? [ingress.value.sg_source] : null
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.default_tags, tomap({
    Name = "kubernetes-${var.aws_cluster_name}-fe-sg"
  }))
}

# Backend
resource "aws_security_group" "be_sg" {
  name   = "kubernetes-${var.aws_cluster_name}-be-sg"
  vpc_id = aws_vpc.main.id

  dynamic "ingress" {
    for_each = var.be_allowed_ingress
    content {
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      cidr_blocks     = ingress.value.cidr != null ? [ingress.value.cidr] : null
      security_groups = ingress.value.sg_source != null ? [ingress.value.sg_source] : null
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.default_tags, tomap({
    Name = "kubernetes-${var.aws_cluster_name}-be-sg"
  }))
}

# Database
resource "aws_security_group" "db_sg" {
  name   = "kubernetes-${var.aws_cluster_name}-db-sg"
  vpc_id = aws_vpc.main.id

  dynamic "ingress" {
    for_each = var.db_allowed_ingress
    content {
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      cidr_blocks     = ingress.value.cidr != null ? [ingress.value.cidr] : null
      security_groups = ingress.value.sg_source != null ? [ingress.value.sg_source] : null
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.default_tags, tomap({
    Name = "kubernetes-${var.aws_cluster_name}-db-sg"
  }))
}

# Ops Node (VPN + K8s Control Plane)
resource "aws_security_group" "ops_sg" {
  name   = "kubernetes-${var.aws_cluster_name}-ops-sg"
  vpc_id = aws_vpc.main.id

  dynamic "ingress" {
    for_each = var.ops_allowed_ingress
    content {
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      cidr_blocks     = ingress.value.cidr != null ? [ingress.value.cidr] : null
      security_groups = ingress.value.sg_source != null ? [ingress.value.sg_source] : null
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.default_tags, tomap({
    Name = "kubernetes-${var.aws_cluster_name}-ops-sg"
  }))
}
########################################################################
