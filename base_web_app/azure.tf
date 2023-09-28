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
resource "azurerm_resource_group" "GSWTF" {
  name     = "globo-app-resource-Group"
  location = "UK South"
}
resource "azurerm_windows_virtual_machine" "GSWTF" {
  name                     = "globo-app-vm"
  resource_group_name      = azurerm_resource_group.GSWTF.name
  location                 = azurerm_resource_group.GSWTF.location
  size                     = "Standard_DS1_v2"
  admin_username           = "gswtfadmin"
  admin_password           = "Password1234!"
  network_interface_ids    = [azurerm_network_interface.GSWTF.id]
  computer_name            = "globo-app-vm"
  enable_automatic_updates = true
  provision_vm_agent       = true
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  os_disk {
    name                 = "globo-app-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  tags = {
    environment = "gswtf"
  }
}
resource "azurerm_virtual_machine_extension" "vm_extension_install_iis" {
  name                       = "vm_extension_install_iis"
  virtual_machine_id         = azurerm_windows_virtual_machine.GSWTF.id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.8"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
        "commandToExecute": "powershell -ExecutionPolicy Unrestricted Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature -IncludeManagementTools"
    }
SETTINGS
}
resource "azurerm_network_interface" "GSWTF" {
  name                = "globo-app-nic"
  location            = azurerm_resource_group.GSWTF.location
  resource_group_name = azurerm_resource_group.GSWTF.name

  ip_configuration {
    name                          = "globo-app-nic-configuration"
    subnet_id                     = azurerm_subnet.GSWTF.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.GSWTF.id
  }
}
resource "azurerm_public_ip" "GSWTF" {
  name                = "globo-app-public-ip"
  resource_group_name = azurerm_resource_group.GSWTF.name
  location            = azurerm_resource_group.GSWTF.location
  allocation_method   = "Dynamic"
}
