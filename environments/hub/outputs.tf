output "hub_vnet_id" {
  description = "Resource ID of the hub VNet — consumed by spoke environments for peering"
  value       = module.hub_network.hub_vnet_id
}

output "hub_vnet_name" {
  description = "Name of the hub VNet"
  value       = module.hub_network.hub_vnet_name
}

output "hub_resource_group_name" {
  description = "Name of the hub resource group — peering resources on the hub side are created here"
  value       = module.resource_group.name
}
output "keyvault_dns_zone_id" {
  value = module.keyvault_dns_zone.zone_id
}

output "keyvault_dns_zone_name" {
  value = module.keyvault_dns_zone.zone_name
}

output "keyvault_dns_zone_resource_group_name" {
  value = module.keyvault_dns_zone.resource_group_name
}