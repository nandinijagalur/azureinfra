output "hub_vnet_id" {
  description = "ID of the hub VNet — needed for peering"
  value       = azurerm_virtual_network.hub.id
}

output "hub_vnet_name" {
  value = azurerm_virtual_network.hub.name
}

output "hub_subnet_ids" {
  description = "Map of subnet name -> subnet ID"
  value       = { for k, v in azurerm_subnet.hub_subnets : k => v.id }
}