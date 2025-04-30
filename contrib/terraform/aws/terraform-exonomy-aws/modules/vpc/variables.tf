variable "aws_cluster_name" { description = "Name of Cluster" }
variable "default_tags" {
  description = "Default tags for all resources"
  type        = map(string)
}

variable "vpc_cidr" {}
variable "public_subnets" { type = list(string) }
variable "private_subnets" { type = list(string) }
variable "db_subnets" { type = list(string) }
variable "ops_subnets" { type = list(string) }
variable "azs" { type = list(string) }
variable "environment" {}

# Security Group Configuration Variables

variable "ops_allowed_ingress" {
  description = "Ops node ingress rules"
  type = list(object({
    from_port = number
    to_port   = number
    protocol  = string
    cidr      = optional(string)
    sg_source = optional(string)
  }))
  default = [
    { from_port = 51820, to_port = 51820, protocol = "udp", cidr = "0.0.0.0/0" } # WireGuard example
  ]
}

variable "db_allowed_ingress" {
  description = "Database ingress rules"
  type = list(object({
    from_port = number
    to_port   = number
    protocol  = string
    cidr      = optional(string)
    sg_source = optional(string)
  }))
}

variable "be_allowed_ingress" {
  description = "Backend ingress rules"
  type = list(object({
    from_port = number
    to_port   = number
    protocol  = string
    cidr      = optional(string)
    sg_source = optional(string)
  }))
}

variable "fe_allowed_ingress" {
  description = "List of frontend ingress rules with flexible sources"
  type = list(object({
    from_port = number
    to_port   = number
    protocol  = string
    cidr      = optional(string)
    sg_source = optional(string)
  }))
  default = [
    { from_port = 80, to_port = 80, protocol = "tcp", cidr = "0.0.0.0/0" },
    { from_port = 443, to_port = 443, protocol = "tcp", cidr = "0.0.0.0/0" }
  ]
}

variable "bastion_allowed_ingress" {
  description = "List of bastion ingress rules with flexible sources"
  type = list(object({
    from_port = number
    to_port   = number
    protocol  = string
    cidr      = optional(string)
    sg_source = optional(string)
  }))
  default = [
    { from_port = 22, to_port = 22, protocol = "tcp", cidr = "0.0.0.0/0" },
  ]
}

