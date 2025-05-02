output "bastion_node_public_ips" {
  value = tolist(aws_instance.bastion_node[*].public_ip)
}

output "fe_node_public_ips" {
  value = tolist(aws_instance.fe_node[*].public_ip)
}

output "fe_node_private_ips" {
  value = tolist(aws_instance.fe_node[*].private_ip)
}

output "be_node_private_ips" {
  value = tolist(aws_instance.be_node[*].private_ip)
}

output "db_node_private_ips" {
  value = tolist(aws_instance.db_node[*].private_ip)
}

output "ops_node_private_ips" {
  value = tolist(aws_instance.ops_node[*].private_ip)
}
