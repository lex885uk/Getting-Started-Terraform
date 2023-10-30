# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}
# Configure the Microsoft Azure Provider
provider "azurerm" {
  #   skip_provider_registration = true # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  features {}
}
# Create a resource group
resource "azurerm_resource_group" "gswtf" {
  name     = var.resource_group_name
  location = var.azure_location

  tags = local.common_tags
}
resource "azurerm_windows_virtual_machine" "gswtf" {
  name                     = var.azure_vm.name
  resource_group_name      = azurerm_resource_group.gswtf.name
  location                 = azurerm_resource_group.gswtf.location
  size                     = var.azure_vm.size
  admin_username           = var.azure_vm.admin_username
  admin_password           = var.azure_vm.admin_password
  network_interface_ids    = [azurerm_network_interface.gswtf.id]
  computer_name            = var.azure_vm.computer_name
  enable_automatic_updates = true
  provision_vm_agent       = true
  source_image_reference {
    publisher = var.source_image.publisher
    offer     = var.source_image.offer
    sku       = var.source_image.sku
    version   = var.source_image.version
  }
  os_disk {
    name                 = var.os_disk.name
    caching              = var.os_disk.caching
    storage_account_type = var.os_disk.storage_account_type
  }

  tags       = local.common_tags
  depends_on = [azurerm_network_interface.gswtf]
}
resource "azurerm_virtual_machine_extension" "vm_extension_install_iis" {
  name                       = var.vm_extension.name
  virtual_machine_id         = azurerm_windows_virtual_machine.gswtf.id
  publisher                  = var.vm_extension.publisher
  type                       = var.vm_extension.type
  type_handler_version       = var.vm_extension.type_handler_version
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell -ExecutionPolicy Unrestricted Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature -IncludeManagementTools"
    }
SETTINGS

  tags       = local.common_tags
  depends_on = [azurerm_windows_virtual_machine.gswtf]
}
resource "azurerm_network_interface" "gswtf" {
  name                = var.network_interface.name
  location            = azurerm_resource_group.gswtf.location
  resource_group_name = azurerm_resource_group.gswtf.name

  ip_configuration {
    name                          = var.ip_configuration.name
    subnet_id                     = azurerm_subnet.gswtf.id
    private_ip_address_allocation = var.ip_configuration.private_ip_address_allocation
    public_ip_address_id          = azurerm_public_ip.gswtf.id
  }
  tags       = local.common_tags
  depends_on = [azurerm_subnet.gswtf]
}
resource "azurerm_public_ip" "gswtf" {
  name                = var.public_ip.name
  resource_group_name = azurerm_resource_group.gswtf.name
  location            = azurerm_resource_group.gswtf.location
  allocation_method   = var.public_ip.allocation_method
}

resource "azurerm_virtual_machine_extension" "vm_extension_enable_aad" {
  name                       = "vm_extension_enable_aad"
  virtual_machine_id         = azurerm_windows_virtual_machine.gswtf.id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
        "TenantID": "7aa8c601-0c14-4b9d-9818-9d4d0baf1ab1"
    }

SETTINGS
}