provider "nutanix" {
  username = var.nutanix_user
  password = var.nutanix_pass
  endpoint = var.nutanix_endpoint
  insecure = true
}

resource "nutanix_virtual_machine" "windows_vm" {
  count         = 3
  name          = "rit-vm-${count.index}"
  cluster_uuid  = var.cluster_id
  num_sockets   = 2
  memory_size_mib = 8192

  disk_list {
    data_source_reference = {
      kind = "image"
      uuid = var.windows_template_id
    }
  }

  nic_list {
    subnet_uuid = var.vlan_id
  }
}

resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/../ansible/inventory/hosts.tpl", {
    vm_ips          = nutanix_virtual_machine.windows_vm[*].nic_list[0].ip_endpoint_list[0].ip,
    admin_vm_user   = var.admin_vm_user,
    admin_vm_pass   = var.admin_vm_password
  })
  filename = "${path.module}/../ansible/inventory/hosts"
}