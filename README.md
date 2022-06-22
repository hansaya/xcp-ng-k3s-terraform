# Kubernetes Cluster deployment using Terraform

Deploy K8S/K3S cluster into xcp-ng using terraform. *This will not install Kubernetes*, only used to provision the VM(s) so that Ansible can take over to complete the installation.

**WORK IN PROGRESS** There are plenty of issues before prime time. Look bellow for known issues.

## Known issues
* Network config issues where VM(s) gets two ip address assigned to it.
* Terraform cannot be ran for the second time without accidentally wiping out the existing primary disk
* Super slow to deploy larger disks. As a work around, expand the disk after installation.
* Disk does not get expanded automatically.

## Create a cloud-init compatible xcp-ng template
Terraform needs a template within xcp-ng to clone to create the VM(s). This can be anything you wish but in this example I'm using Ubuntu 20.04 and 22.04. Template requires cloud-init to be functioning so that we can inject SSH keys and other configs into the VM at deployment.
```
# Install Ubuntu 20.04 or 22.04 normally

# Mount guest_tools.iso and install the guest tools
sudo mount /dev/cdrom /mnt
sudo dpkg -i /mnt/Linux/xe-guest-utilities_X.X.X-XXXX_amd64.deb
sudo umount /mnt

# Update and reboot
sudo apt update && sudo apt upgrade -y
sudo reboot

# Purge existing cloud-init configs and packages
sudo apt purge cloud-init cloud-initramfs-dyn-netconf cloud-initramfs-copymods -y
sudo rm -rf /etc/cloud/; sudo rm -rf /var/lib/cloud/

# Start fresh with cloud-init
sudo apt update && sudo apt install cloud-init cloud-initramfs-growroot -y

# Reconfigure and only select nocloud
sudo dpkg-reconfigure cloud-init
sudo systemctl enable cloud-init

# Shutdown and convert into a template
sudo shutdown now
```
## Generate SSH keys
```
ssh-keygen -t rsa -b 4096 -C "admin@example.com" -f ~/.ssh/k3scluster
```
## Run terraform
Before getting started, make sure to complete this checklist
* Test your template by manually creating a VM using the template.
* Create a network interface if you are using VLANs.
* Dedicate a static sequential ip range for these VM(s).
* Figure out the storage medium for K8S/K3S cluster.
* Xen Orchestra running and accessible.
### Install terraform
Follow https://www.terraform.io/downloads
### Modify the config.auto.tfvars.sample to fit your setup
Rename the `config.auto.tfvars.sample` to `config.auto.tfvars`s and fill the blanks. Otherwise pass in the variables through CLI
```
mv config.auto.tfvars.sample config.auto.tfvars
```
### Deploy
```
terraform init
terraform plan
terraform apply
```
### Use inventory files for Ansible
You can use the auto generated host file for Ansible. To install k3s, I recommend the great work by https://github.com/itwars/k3s-ansible or https://github.com/212850a/k3s-ansible. If you are experimenting alot, create a sym link between inventory/hosts.ini and k3s-ansible/inventory/my-cluster/hosts.ini and set ansible_user in group_vars/all.yml.