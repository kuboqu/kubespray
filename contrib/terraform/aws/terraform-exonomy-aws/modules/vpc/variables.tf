variable "vpc_cidr" {}
variable "public_subnets" { type = list(string) }
variable "private_subnets" { type = list(string) }
variable "db_subnets" { type = list(string) }
variable "ops_subnets" { type = list(string) }
variable "azs" { type = list(string) }
variable "environment" {}
