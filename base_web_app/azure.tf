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

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "GSWTF" {
  name                = "globo-app-vnet"
  resource_group_name = azurerm_resource_group.GSWTF.name
  location            = azurerm_resource_group.GSWTF.location
  address_space       = ["10.0.0.0/16"]
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
resource "azurerm_subnet" "GSWTF" {
  name                 = "globo-app-subnet"
  resource_group_name  = azurerm_resource_group.GSWTF.name
  virtual_network_name = azurerm_virtual_network.GSWTF.name
  address_prefixes     = ["10.0.0.0/24"]

}

resource "azurerm_route_table" "GSWTF" {
  name                = "globo-app-route-table"
  location            = azurerm_resource_group.GSWTF.location
  resource_group_name = azurerm_resource_group.GSWTF.name

  route {
    name           = "routeinternet"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }
  route {
    name           = "routelocal"
    address_prefix = "10.1.0.0/16"
    next_hop_type  = "VnetLocal"
  }
}

resource "azurerm_subnet_route_table_association" "GSWTF" {
  subnet_id      = azurerm_subnet.GSWTF.id
  route_table_id = azurerm_route_table.GSWTF.id
}

resource "azurerm_network_security_group" "gswtf-nsg" {
  name                = "globo-app-nsg"
  location            = azurerm_resource_group.GSWTF.location
  resource_group_name = azurerm_resource_group.GSWTF.name
}

resource "azurerm_network_security_rule" "gswtf-nsg-allow-http" {
  name                        = "globo-app-nsg-allow-http"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.GSWTF.name
  network_security_group_name = azurerm_network_security_group.gswtf-nsg.name
}

resource "azurerm_subnet_network_security_group_association" "gswtf-nsg" {
  subnet_id                 = azurerm_subnet.GSWTF.id
  network_security_group_id = azurerm_network_security_group.gswtf-nsg.id
}
