output "azure_vm_public_ip" {
  value = azurerm_windows_virtual_machine.gswtf.public_ip_address
}
output "bastion_public_ip" {
  value = azurerm_public_ip.bastion.ip_address
}