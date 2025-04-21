variable "ami_id" {}
variable "instance_type" {}
variable "subnet_id" {}
variable "key_pair_name" {}
variable "security_group_ids" { type = list(string) }
variable "instance_name" {}
variable "environment" {}
variable "role" {}
variable "extra_tags" { default = {} }
