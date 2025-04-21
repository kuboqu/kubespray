variable "region" { default = "us-east-1" }
variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "vpc_cidr" { default = "10.100.0.0/16" }
variable "public_subnets" { default = ["10.100.1.0/24", "10.100.2.0/24"] }
variable "azs" { default = ["us-east-1a", "us-east-1b"] }

variable "environment" { default = "dev" }
variable "ami_id" {}
variable "key_pair_name" {}
