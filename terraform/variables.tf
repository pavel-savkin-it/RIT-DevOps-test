variable "nutanix_user" {}
variable "nutanix_pass" { sensitive = true }
variable "nutanix_endpoint" {}
variable "cluster_id" {}
variable "windows_template_id" {}
variable "vlan_id" {}
variable "admin_vm_user" { default = "Administrator" }
variable "admin_vm_password" { sensitive = true }
variable "zabbix_server_ip" {}