variable "user" {
  description = "Xen Orchestra User"
  sensitive = true
  default = "admin@admin.net"
}

variable "password" {
  description = "Xen Orchestra Password"
  sensitive = true
}

variable "host" {
  description = "URL of the Xen Orchestra. Use 'wss' for HTTPS and 'ws' for HTTP"
  # Must be ws or wss
}

variable "pool_name" {
  description = "XEN pool name"
}

variable "ssh_pvt_key" {
  description = "SSH Key to use"
}

variable "storage_name" {
  description = "Storage Medium to use"
  default = "Local Storage"
}

variable "num_k3s_masters" {
  description = "Number of Master VM(s)"
  default = 1 
}

variable "num_k3s_masters_mem" {
  description = "Master VM RAM allocation"
  default = "4073733632"
}

variable "num_k3s_workers" {
  description = "Number of Worker VM(s)"
  default = 1
}

variable "num_k3s_workers_mem" {
  description = "Worker VM RAM allocation"
  default = "4073733632"
}

variable "num_k3s_nodes_worker_storage" {
  description = "Worker VM disk size"
  default = "10212254720"
}

variable "num_k3s_nodes_master_storage" {
  description = "Master VM disk size"
  default = "10212254720"
}

variable "start_on_boot" {
  description = "Start the VM on boot"
  default = true
}

variable "number_of_cores" {
  description = "CPU cores"
  default = 4
}

variable "tamplate_name" {
  description = "Name of the cloud-init template"
}

variable "ip_sub" {
  description = "Network Sub"
  default = "192.168.1.0"
}

variable "ip_sub_mask" {
  description = "Network Sub Mask"
  default = 24
}

variable "master_ip_start" {
  description = "Start of the master nodes ip example: 170 (192.168.1.170..171..172)"
  default = 180
}

variable "worker_ip_start" {
  description = "Start of the master nodes ip example: 180 (192.168.1.180..181..182)"
  default = 190
}

variable "default_gateway" {
  description = "Default gateway"
  default = "192.168.1.1"
}

variable "dns" {
  description = "Name Server"
  default = "192.168.1.1"
}

variable "network_name" {
  description = "Network Name"
  default = "Pool-wide network associated with eth0"
}
