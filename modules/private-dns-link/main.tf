resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  name                  = var.link_name
  resource_group_name  = var.dns_zone_resource_group_name
  private_dns_zone_name = var.dns_zone_name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
  tags                  = var.tags
}