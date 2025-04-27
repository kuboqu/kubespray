region          = "eu-central-1"
vpc_cidr        = "10.100.0.0/16"
public_subnets  = ["10.100.1.0/24"]
private_subnets = ["10.100.2.0/24"]
db_subnets      = ["10.100.3.0/24"]
ops_subnets     = ["10.100.4.0/24"]
azs             = ["eu-central-1a"]

environment   = "dev"
ami_id        = "ami-0123456789abcdef0"
key_pair_name = "bohdan <bohdan@newexchanger.com> t480"
