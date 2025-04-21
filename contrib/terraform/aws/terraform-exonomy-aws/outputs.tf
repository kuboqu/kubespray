output "ops_node_ip" {
  value = aws_instance.ops_node.public_ip
}

output "db_node_ip" {
  value = aws_instance.db_node.private_ip
}

output "workload_nodes_ips" {
  value = [for instance in aws_instance.workload_nodes : instance.private_ip]
}
