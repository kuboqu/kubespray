terraform output -json | jq '. | {ops_node_ip: .operations_node.private_ip, db_node_ip: .database_node.private_ip, workload_node_ips: [.workload_nodes[].private_ip]}' | \
  jinja2 inventory.tpl > inventory.ini
