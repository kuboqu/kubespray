[all]
ops-node ansible_host=${ops_node_ip}
db-node ansible_host=${db_node_ip}
%{ for ip in workload_nodes_ips ~}
workload-node-${index(ip)+1} ansible_host=${ip}
%{ endfor }

[kube_control_plane]
ops-node

[etcd]
ops-node

[kube_node]
db-node
%{ for ip in workload_nodes_ips ~}
workload-node-${index(ip)+1}
%{ endfor }
