host = "wss://xen.example.com"
user = "admin@admin.net"
password = "admin"
pool_name = "home"

tamplate_vm_name = "cloudinit-template"
storage_name = "NVME"
ssh_pvt_key = "/home/bob/.ssh/k3scluster"
start_on_boot = true
number_of_cores = 10

num_k3s_masters = 2 
# 4 gigs of memory
num_k3s_masters_mem = "4073733632"
# 10 gigs of disk
num_k3s_nodes_master_storage = "10212254720"

num_k3s_workers = 2
num_k3s_workers_mem = "4073733632"
num_k3s_nodes_worker_storage = "10212254720"

ip_sub = "192.168.1.0"
ip_sub_mask = 24
master_ip_start = 180
worker_ip_start = 190
default_gateway = "192.168.1.1"
dns = "192.168.1.1"
