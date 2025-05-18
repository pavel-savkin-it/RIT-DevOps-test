[windows]
%{ for ip in vm_ips ~}
${ip}
%{ endfor ~}

[windows:vars]
ansible_user=Administrator
ansible_password=${admin_password}
ansible_connection=ritrm
ansible_winrm_transport=basic