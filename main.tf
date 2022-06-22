terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = ">=2.8.0"
    }
    xenorchestra = {
      source = "terra-farm/xenorchestra"
      version = "~> 0.9"
    }
  }
}

# Configure the XenServer Provider
provider "xenorchestra" {
  # Must be ws or wss
  url      = var.host # Or set XOA_URL environment variable
  username = var.user              # Or set XOA_USER environment variable
  password = var.password             # Or set XOA_PASSWORD environment variable
  insecure = false
}

# Get the generated public key
data "local_file" "ssh_pub_key" {
    filename = "${var.ssh_pvt_key}.pub"
}

data "xenorchestra_network" "net" {
  name_label = var.network_name
  pool_id    = data.xenorchestra_pool.pool.id
  # vlan = 2
}

resource "xenorchestra_cloud_config" "workers" {
  count = var.num_k3s_workers
  name = "k3s-worker-${count.index}"
  template = templatefile("./templates/cloud_config.tftpl", {
    hostname = "k3s-worker-${count.index}"
    domain   = "hansperera.com"
    sshkey   = data.local_file.ssh_pub_key.content
  })
}

resource "xenorchestra_cloud_config" "masters" {
  count = var.num_k3s_masters
  name = "k3s-master-${count.index}"
  template = templatefile("./templates/cloud_config.tftpl", {
    hostname = "k3s-master-${count.index}"
    domain   = "hansperera.com"
    sshkey   = data.local_file.ssh_pub_key.content
  })
}

resource "xenorchestra_cloud_config" "network_masters" {
  count = var.num_k3s_masters
  name = "k3s-master-net-${count.index}"
  # Template the cloudinit if needed
  template = templatefile("./templates/cloud_config_net.tftpl", {
    ip       = "${cidrhost("${var.ip_sub}/${var.ip_sub_mask}", var.master_ip_start+count.index)}/${var.ip_sub_mask}"
    gateway  = var.default_gateway
    dns      = var.dns
  })
}

resource "xenorchestra_cloud_config" "network_workers" {
  count = var.num_k3s_workers
  name = "k3s-worker-net-${count.index}"
  # Template the cloudinit if needed
  template = templatefile("./templates/cloud_config_net.tftpl", {
    ip       = "${cidrhost("${var.ip_sub}/${var.ip_sub_mask}", var.worker_ip_start+count.index)}/${var.ip_sub_mask}"
    gateway  = var.default_gateway
    dns      = var.dns
  })
}

data "xenorchestra_sr" "default" {
  name_label = var.storage_name
  pool_id = data.xenorchestra_pool.pool.id
}

data "xenorchestra_pool" "pool" {
    name_label = var.pool_name
}

data "xenorchestra_template" "template" {
    name_label = var.tamplate_name
}

resource "xenorchestra_vm" "xen_vm_master" {
  count            = var.num_k3s_masters
  name_label       = "k3s-master-${count.index}"
  cloud_config     = xenorchestra_cloud_config.masters[count.index].template
  cloud_network_config = xenorchestra_cloud_config.network_masters[count.index].template
  name_description = "K3S"
  template         = data.xenorchestra_template.template.id
  memory_max       = var.num_k3s_masters_mem
  cpus             = var.number_of_cores
  wait_for_ip      = true
  auto_poweron     = var.start_on_boot
  high_availability = "best-effort"
  exp_nested_hvm   = true
  disk {
    sr_id = data.xenorchestra_sr.default.id
    name_label = "k3s-master-${count.index} root volume"
    size = var.num_k3s_nodes_master_storage
  }

  network {
    network_id = data.xenorchestra_network.net.id
  }

  tags = [
    "Ubuntu",
    "K3S",
  ]

  timeouts {
    create = "20m"
  }
}

resource "xenorchestra_vm" "xen_vm_worker" {
  count            = var.num_k3s_workers
  name_label       = "k3s-worker-${count.index}"
  cloud_config     = xenorchestra_cloud_config.workers[count.index].template
  cloud_network_config = xenorchestra_cloud_config.network_workers[count.index].template
  name_description = "K3S"
  template         = data.xenorchestra_template.template.id
  memory_max       = var.num_k3s_workers_mem
  cpus             = var.number_of_cores
  wait_for_ip      = true
  auto_poweron     = var.start_on_boot
  high_availability = "best-effort"
  exp_nested_hvm   = true
  disk {
    sr_id = data.xenorchestra_sr.default.id
    name_label = "k3s-worker-${count.index} root volume"
    size = var.num_k3s_nodes_worker_storage
  }

  network {
    network_id = data.xenorchestra_network.net.id
  }

  tags = [
    "Ubuntu",
    "K3S",
  ]

  timeouts {
    create = "20m"
  }

  # Wait for masters vm(s)
  depends_on = [xenorchestra_vm.xen_vm_master]
}

data "template_file" "k8s" {
  template = file("./templates/k8s.tpl")
  vars = {
    k3s_master_ip = "${join("\n", [for instance in xenorchestra_vm.xen_vm_master : join("", [instance.ipv4_addresses[0], " ansible_ssh_private_key_file=", var.ssh_pvt_key])])}"
    k3s_node_ip   = "${join("\n", [for instance in xenorchestra_vm.xen_vm_worker : join("", [instance.ipv4_addresses[0], " ansible_ssh_private_key_file=", var.ssh_pvt_key])])}"
  }
}

resource "local_file" "k8s_file" {
  content  = data.template_file.k8s.rendered
  filename = "inventory/hosts.ini"
}

output "Master-IPS" {
  value = ["${xenorchestra_vm.xen_vm_master.*.ipv4_addresses}"]
}
output "worker-IPS" {
  value = ["${xenorchestra_vm.xen_vm_worker.*.ipv4_addresses}"]
}
