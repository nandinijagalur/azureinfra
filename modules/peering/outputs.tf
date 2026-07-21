output "hub_to_spoke_peering_ids" {
  value = { for k, v in azurerm_virtual_network_peering.hub_to_spoke : k => v.id }
}

output "spoke_to_hub_peering_ids" {
  value = { for k, v in azurerm_virtual_network_peering.spoke_to_hub : k => v.id }
}