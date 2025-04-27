output "fe_node_ip" {
  value = aws_instance.fe_node.public_ip
}

output "be_node_ip" {
  value = aws_instance.be_node.private_ip
}

output "db_node_ip" {
  value = aws_instance.db_node.private_ip
}

output "ops_node_ip" {
  value = aws_instance.ops_node.private_ip
}
