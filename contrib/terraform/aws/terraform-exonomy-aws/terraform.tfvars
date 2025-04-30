#Global Vars
region = "eu-central-1"

vpc_cidr        = "10.100.0.0/16"
public_subnets  = ["10.100.1.0/24"]
private_subnets = ["10.100.2.0/24"]
db_subnets      = ["10.100.3.0/24"]
ops_subnets     = ["10.100.4.0/24"]
azs             = ["eu-central-1a"]

ami_id        = "ami-03250b0e01c28d196" # Ubuntu Server 24.04 LTS (HVM), SSD Volume Type (64-bit (x86))
key_pair_name = "bohdan@newexchanger.com"

#Settings AWS ELB
aws_nlb_api_port    = 6443
k8s_secure_api_port = 6443
aws_cluster_name    = "exonomy"
default_tags = {
  Env     = "dev"
  Cluster = "exonomy"
}
