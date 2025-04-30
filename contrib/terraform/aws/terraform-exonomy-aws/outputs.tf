output "fe_node_ids" {
  value = tolist(aws_instance.fe_node[*].private_ip)
}

output "be_node_ids" {
  value = tolist(aws_instance.be_node[*].private_ip)
}

output "db_node_ids" {
  value = tolist(aws_instance.db_node[*].private_ip)
}

output "ops_node_ids" {
  value = tolist(aws_instance.ops_node[*].private_ip)
}
