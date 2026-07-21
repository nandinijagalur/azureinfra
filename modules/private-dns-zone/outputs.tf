output "zone_id" {
  value = azurerm_private_dns_zone.this.id
}

output "zone_name" {
  value = azurerm_private_dns_zone.this.name
}

output "resource_group_name" {
  value = var.resource_group_name
}