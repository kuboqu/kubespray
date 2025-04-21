[all]
ops-node ansible_host=${ops_node_ip} ip=${ops_node_ip}
db-node ansible_host=${db_node_ip} ip=${db_node_ip}
%{ for ip in workload_node_ips ~}
workload-node-${index(ip) + 1} ansible_host=${ip} ip=${ip}
%{ endfor }

[kube_control_plane]
ops-node

[etcd]
ops-node

[kube_node]
%{ for ip in workload_node_ips ~}
workload-node-${index(ip) + 1}
%{ endfor }
db-node

[calico_rr]
ops-node
