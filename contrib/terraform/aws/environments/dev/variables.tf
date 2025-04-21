variable "aws_region" {
  default = "eu-central-1"
}

variable "key_pair_name" {
  type = string
}

variable "vpc_cidr" {
  default = "10.100.0.0/16"
}

variable "public_subnets" {
  default = ["10.100.1.0/24", "10.100.2.0/24"]
}

variable "ami_id" {
  default = "ami-1234567890abcdef0" # Amazon Linux 2 or Ubuntu for Kubespray
}
