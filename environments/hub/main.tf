module "resource_group" {
  source   = "../../modules/resource-group"
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

module "hub_network" {
  source               = "../../modules/hub-network"
  resource_group_name  = module.resource_group.name
  location             = var.location
  hub_vnet_name        = var.hub_vnet_name
  hub_address_space    = var.hub_address_space
  subnets              = var.subnets
  tags                 = var.tags
}
module "keyvault" {
  source               = "../../modules/keyvault"
  resource_group_name = module.resource_group.name
  location             = var.location
  keyvault_name        = var.keyvault_name
  tenant_id            = var.tenant_id
  tags                 = var.tags
}

module "keyvault_dns_zone" {
  source               = "../../modules/private-dns-zone"
  resource_group_name = module.resource_group.name
  zone_name            = "privatelink.vaultcore.azure.net"
  hub_vnet_id          = module.hub_network.hub_vnet_id
  tags                 = var.tags
}