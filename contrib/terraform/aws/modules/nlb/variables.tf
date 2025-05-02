variable "aws_cluster_name" { description = "Name of Cluster" }
variable "default_tags" {
  description = "Default tags for all resources"
  type        = map(string)
}

variable "k8s_secure_api_port" { description = "Secure Port of K8S API Server" }
variable "vpc_id" { description = "AWS VPC ID" }
variable "subnets" { type = list(string) }
variable "aws_nlb_api_port" { description = "Port for AWS NLB" }
