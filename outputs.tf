output "add_ssh_known_hosts" {
  description = "Commands to add instance IPs to known_hosts"
  value       = join("&&", [
    for ip in module.ec2_instance[*].public_ip : 
    "ssh-keygen -R ${ip} 2>/dev/null; ssh-keyscan -H ${ip} >> ~/.ssh/known_hosts"
  ])
}

output "fill_ansible_inventory" {
  description = "Commands to fill Ansible inventory file"
  value       = module.ec2_instance[*].public_ip
}