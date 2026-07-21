resource "azurerm_private_dns_zone" "this" {
  name                = var.zone_name
  resource_group_name = var.resource_group_name
  tags                 = var.tags
}

# Link the hub's own VNet so anything in the hub can also resolve private endpoints
resource "azurerm_private_dns_zone_virtual_network_link" "hub_link" {
  name                  = "link-hub"
  resource_group_name  = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.this.name
  virtual_network_id    = var.hub_vnet_id
  registration_enabled  = false
  tags                  = var.tags
}