variable "resource_group_name" {
  type    = string
  default = "globo-app-resource-group"
}

variable "azure_location" {
  type    = string
  default = "UK South"
}

variable "azure_vm" {
  type = map(string)
  default = {
    name           = "globo-app-vm"
    size           = "Standard_DS1_v2"
    admin_username = "gswtfadmin"
    admin_password = "Password1234!"
    computer_name  = "globo-app-vm"
  }
}

variable "source_image" {
  type = map(string)
  default = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

variable "os_disk" {
  type = map(string)
  default = {
    name                 = "globo-app-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

variable "vm_extension" {
  type = map(string)
  default = {
    name                 = "vm_extension_install_iis"
    publisher            = "Microsoft.Compute"
    type                 = "CustomScriptExtension"
    type_handler_version = "1.8"
  }
}

variable "network_interface" {
  type = map(string)
  default = {
    name = "globo-app-nic"
  }
}

variable "ip_configuration" {
  type = map(string)
  default = {
    name                          = "globo-app-nic-configuration"
    private_ip_address_allocation = "Dynamic"
  }
}

variable "public_ip" {
  type = map(string)
  default = {
    name              = "globo-app-public-ip"
    allocation_method = "Dynamic"
  }
}

variable "virtual_network_name" {
  type    = string
  default = "globo-app-vnet"
}

variable "virtual_network_address_space" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_name" {
  type    = string
  default = "globo-app-subnet"
}

variable "subnet_address_prefixes" {
  type    = string
  default = "10.0.0.0/24"
}

variable "route_table" {
  type = map(string)
  default = {
    name = "globo-app-route-table"
  }
}

variable "network_security_group_name" {
  type    = string
  default = "globo-app-nsg"
}

variable "nsg_http_rule" {
  type = map(string)
  default = {
    name                       = "globo-app-nsg-allow-http"
    priority                   = "100"
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

variable "route_internet" {
  type = map(string)
  default = {
    name           = "routeinternet"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }
}

variable "route_local" {
  type = map(string)
  default = {
    name           = "routelocal"
    address_prefix = "10.1.0.0/16"
    next_hop_type  = "VnetLocal"
  }
}

variable "bastion_name" {
  type    = string
  default = "globo-app-vnet-bastion"
}

variable "bastion_ip_configuration_name" {
  type    = string
  default = "globo-app-bastion-ip-configuration"
}

variable "bastion_private_ip_address_allocation" {
  type    = string
  default = "Dynamic"
}

variable "bastion_subnet_name" {
  type    = string
  default = "AzureBastionSubnet"
}

variable "bastion_subnet_address_prefixes" {
  type    = string
  default = "10.0.1.0/26"

}
variable "bastion_public_ip_name" {
  type    = string
  default = "globo-app-vnet-ip"
}

variable "bastion_public_ip_allocation_method" {
  type    = string
  default = "Static"
}

variable "bastion_public_ip_sku" {
  type    = string
  default = "Standard"
}
