[all]
${bastion_node_connection_string}
${ops_node_connection_string}
${db_node_connection_string}
${be_node_connection_string}
${fe_node_connection_string}

[bastion]
${bastion_node_list}

[kube_control_plane]
${ops_node_list}

[kube_node]
${db_node_list}
${be_node_list}
${fe_node_list}

[etcd]
${ops_node_list}

[k8s_cluster:children]
kube_control_plane
kube_node

[k8s_cluster:vars]
${nlb_api_fqdn}

[all:vars]
ansible_user="${node_user}"
ansible_ssh_common_args="-o IdentitiesOnly=yes"
ansible_ssh_private_key_file="${ssh_private_key_file}"
local_release_dir="${ansible_local_release_dir}" 
