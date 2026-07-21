output "spoke_vnet_id" {
  description = "ID of the spoke VNet — needed for peering"
  value       = azurerm_virtual_network.spoke.id
}

output "spoke_vnet_name" {
  value = azurerm_virtual_network.spoke.name
}

output "spoke_subnet_ids" {
  value = { for k, v in azurerm_subnet.spoke_subnets : k => v.id }
}