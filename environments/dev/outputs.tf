output "dev_vnet_id" {
  value = module.spoke_network.spoke_vnet_id
}

output "dev_vnet_name" {
  value = module.spoke_network.spoke_vnet_name
}

output "dev_resource_group_name" {
  value = module.resource_group.name
}

output "dev_keyvault_uri" {
  value = module.keyvault.keyvault_uri
}
output "sql_server_name" {
  value = module.database.sql_server_name
}

output "sql_database_name" {
  value = module.database.database_name
}