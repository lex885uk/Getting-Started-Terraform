# Create a virtual network within the resource group
resource "azurerm_virtual_network" "GSWTF" {
  name                = var.virtual_network_name
  resource_group_name = azurerm_resource_group.GSWTF.name
  location            = azurerm_resource_group.GSWTF.location
  address_space       = [var.virtual_network_address_space]

  tags = local.common_tags
}
resource "azurerm_subnet" "GSWTF" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.GSWTF.name
  virtual_network_name = azurerm_virtual_network.GSWTF.name
  address_prefixes     = [var.subnet_address_prefixes]
}
resource "azurerm_route_table" "GSWTF" {
  name                = var.route_table.name
  location            = azurerm_resource_group.GSWTF.location
  resource_group_name = azurerm_resource_group.GSWTF.name

  route {
    name           = var.route_internet.name
    address_prefix = var.route_internet.address_prefix
    next_hop_type  = var.route_internet.next_hop_type
  }
  route {
    name           = var.route_local.name
    address_prefix = var.route_local.address_prefix
    next_hop_type  = var.route_local.next_hop_type
  }
  tags = local.common_tags
}

resource "azurerm_subnet_route_table_association" "GSWTF" {
  subnet_id      = azurerm_subnet.GSWTF.id
  route_table_id = azurerm_route_table.GSWTF.id
}

resource "azurerm_network_security_group" "gswtf-nsg" {
  name                = var.network_security_group_name
  location            = azurerm_resource_group.GSWTF.location
  resource_group_name = azurerm_resource_group.GSWTF.name

}
resource "azurerm_network_security_rule" "gswtf-nsg-allow-http" {
  name                        = var.nsg_http_rule.name
  priority                    = var.nsg_http_rule.priority
  direction                   = var.nsg_http_rule.direction
  access                      = var.nsg_http_rule.access
  protocol                    = var.nsg_http_rule.protocol
  source_port_range           = var.nsg_http_rule.source_port_range
  destination_port_range      = var.nsg_http_rule.destination_port_range
  source_address_prefix       = var.nsg_http_rule.source_address_prefix
  destination_address_prefix  = var.nsg_http_rule.destination_address_prefix
  resource_group_name         = azurerm_resource_group.GSWTF.name
  network_security_group_name = azurerm_network_security_group.gswtf-nsg.name
}

resource "azurerm_subnet_network_security_group_association" "gswtf-nsg" {
  subnet_id                 = azurerm_subnet.GSWTF.id
  network_security_group_id = azurerm_network_security_group.gswtf-nsg.id
}
