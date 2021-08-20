output "public_ip" {
  value = azurerm_linux_virtual_machine.vm.public_ip_address
}

output "private_ip" {
  value = azurerm_linux_virtual_machine.vm.private_ip_address
}

output "data_disk_id" {
  value = azurerm_managed_disk.data_disk.id
}

output "vm_id" {
  value = azurerm_linux_virtual_machine.vm.id
}
