# Create a virtual network within the resource group
resource "azurerm_virtual_network" "gswtf" {
  name                = var.virtual_network_name
  resource_group_name = azurerm_resource_group.gswtf.name
  location            = azurerm_resource_group.gswtf.location
  address_space       = [var.virtual_network_address_space]

  tags       = local.common_tags
  depends_on = [azurerm_resource_group.gswtf]
}
resource "azurerm_subnet" "gswtf" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.gswtf.name
  virtual_network_name = azurerm_virtual_network.gswtf.name
  address_prefixes     = [var.subnet_address_prefixes]

  depends_on = [azurerm_virtual_network.gswtf]
}
resource "azurerm_route_table" "gswtf" {
  name                = var.route_table.name
  location            = azurerm_resource_group.gswtf.location
  resource_group_name = azurerm_resource_group.gswtf.name

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

resource "azurerm_subnet_route_table_association" "gswtf" {
  subnet_id      = azurerm_subnet.gswtf.id
  route_table_id = azurerm_route_table.gswtf.id
}

resource "azurerm_network_security_group" "gswtf-nsg" {
  name                = var.network_security_group_name
  location            = azurerm_resource_group.gswtf.location
  resource_group_name = azurerm_resource_group.gswtf.name

  tags = local.common_tags

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
  resource_group_name         = azurerm_resource_group.gswtf.name
  network_security_group_name = azurerm_network_security_group.gswtf-nsg.name

  depends_on = [azurerm_network_security_group.gswtf-nsg]
}

resource "azurerm_subnet_network_security_group_association" "gswtf-nsg" {
  subnet_id                 = azurerm_subnet.gswtf.id
  network_security_group_id = azurerm_network_security_group.gswtf-nsg.id

  depends_on = [azurerm_network_security_group.gswtf-nsg, azurerm_subnet.gswtf]
}

resource "azurerm_subnet" "bastion" {
  name                 = var.bastion_subnet_name
  resource_group_name  = azurerm_resource_group.gswtf.name
  virtual_network_name = azurerm_virtual_network.gswtf.name
  address_prefixes     = [var.bastion_subnet_address_prefixes]

  depends_on = [azurerm_virtual_network.gswtf]

}
resource "azurerm_public_ip" "bastion" {
  name                = var.bastion_public_ip_name
  location            = azurerm_resource_group.gswtf.location
  resource_group_name = azurerm_resource_group.gswtf.name
  allocation_method   = var.bastion_public_ip_allocation_method
  sku                 = var.bastion_public_ip_sku
}
