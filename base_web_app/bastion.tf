# resource "azurerm_bastion_host" "gswtf" {
#   name                = var.bastion_name
#   location            = azurerm_resource_group.gswtf.location
#   resource_group_name = azurerm_resource_group.gswtf.name
#   ip_configuration {
#     name                          = var.bastion_ip_configuration_name
#     subnet_id                     = azurerm_subnet.bastion.id
#     public_ip_address_id          = azurerm_public_ip.bastion.id
#   }
#   tags = local.common_tags

# }