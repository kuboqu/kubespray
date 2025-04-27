variable "vpc_cidr" {}
variable "public_subnets" { type = list(string) }
variable "private_subnets" { type = list(string) }
variable "db_subnets" { type = list(string) }
variable "ops_subnets" { type = list(string) }
variable "azs" { type = list(string) }
variable "environment" {}

# Security Group Configuration Variables

# Frontend (fe_sg)
variable "fe_allowed_rules" {
  description = "List of ingress rules for frontend security group"
  type = list(object({
    from_port = number
    to_port   = number
    protocol  = string
    cidr      = string
  }))
  default = [
    { from_port = 80,  to_port = 80,  protocol = "tcp", cidr = "0.0.0.0/0" },
    { from_port = 443, to_port = 443, protocol = "tcp", cidr = "0.0.0.0/0" }
  ]
}

# Backend (be_sg)
variable "be_allowed_rules" {
  description = "List of ingress rules for backend security group"
  type = list(object({
    from_port = number
    to_port   = number
    protocol  = string
    sg_source = string
  }))
}

# Database (db_sg)
variable "db_allowed_rules" {
  description = "List of ingress rules for database security group"
  type = list(object({
    from_port = number
    to_port   = number
    protocol  = string
    sg_source = string
  }))
}

# Ops node (ops_sg)
variable "ops_allowed_rules" {
  description = "List of ingress rules for ops security group"
  type = list(object({
    from_port = number
    to_port   = number
    protocol  = string
    cidr      = string
  }))
  default = [
    { from_port = 51820, to_port = 51820, protocol = "udp", cidr = "0.0.0.0/0" }
  ]
}
