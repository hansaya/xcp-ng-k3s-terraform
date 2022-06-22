[k3s_server]
${k3s_master_ip}

[k3s_agent]
${k3s_node_ip}

[k3s_cluster:children]
k3s_server
k3s_agent