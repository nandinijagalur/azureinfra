resource "azurerm_private_endpoint" "this" {
  name                = var.name
  location             = var.location
  resource_group_name = var.resource_group_name
  subnet_id            = var.subnet_id
  tags                 = var.tags

  private_service_connection {
    name                           = "${var.name}-connection"
    private_connection_resource_id = var.private_connection_resource_id
    subresource_names               = [var.subresource_name]
    is_manual_connection             = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.dns_zone_id]
  }
}