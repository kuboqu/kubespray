variable "region" { default = "eu-central-1" }
variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "vpc_cidr" { default = "10.100.0.0/16" }
variable "public_subnets" { default = ["10.100.1.0/24"] }
variable "private_subnets" { default = ["10.100.2.0/24"] }
variable "db_subnets" { default = ["10.100.3.0/24"] }
variable "ops_subnets" { default = ["10.100.4.0/24"] }
variable "azs" { default = ["eu-central-1a"] }

variable "environment" { default = "dev" }
variable "ami_id" {}
variable "key_pair_name" {}

# EC2 Volume Sizes (GB)
variable "ops_node_volume_size" { default = 100 }
variable "db_node_volume_size" { default = 100 }
variable "be_node_volume_size" { default = 100 }
variable "fe_node_volume_size" { default = 50 }
