output "fill_ansible_inventory" {
  description = "Commands to fill Ansible inventory file"
  value       = module.ec2_instance[*].public_ip
}