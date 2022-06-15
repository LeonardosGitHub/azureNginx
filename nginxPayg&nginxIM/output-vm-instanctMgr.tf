#############################
## Azure Nginx VM - Output ##
#############################

output "nginx_IM_vm_name" {
  description = "Virtual Machine name"
  value       = azurerm_linux_virtual_machine.nginx-IM-vm.name
}

output "nginx_IM_vm_ip_address" {
  description = "Virtual Machine IP Address"
  value       = azurerm_public_ip.nginx-IM-vm-ip.ip_address
}

output "nginx_IM_vm_admin_username" {
  description = "Administrator Username for the Virtual Machine"
  value       = var.nginx_admin_username
}


