data "terraform_remote_state" "hub" {
  backend = "azurerm"
  config = {
    resource_group_name  = "rg_terraform_state"
    storage_account_name = "terraformstatesacac"
    container_name        = "tfstateterraformlandingzone"
    key                    = "hub.terraform.tfstate"
  }
}

module "resource_group" {
  source   = "../../modules/resource-group"
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

module "spoke_network" {
  source               = "../../modules/spoke-network"
  resource_group_name = module.resource_group.name
  location             = var.location
  spoke_vnet_name      = var.vnet_name
  spoke_address_space  = var.address_space
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

module "peering" {
  source                  = "../../modules/peering"
  hub_vnet_name            = data.terraform_remote_state.hub.outputs.hub_vnet_name
  hub_vnet_id              = data.terraform_remote_state.hub.outputs.hub_vnet_id
  hub_resource_group_name = data.terraform_remote_state.hub.outputs.hub_resource_group_name

  spokes = {
    uat = {
      vnet_name            = module.spoke_network.spoke_vnet_name
      vnet_id              = module.spoke_network.spoke_vnet_id
      resource_group_name = module.resource_group.name
    }
  }
}
module "rbac" {
  source               = "../../modules/rbac"
  resource_group_name = module.resource_group.name
  location             = var.location
  identity_name        = "id-uat-app"
  keyvault_id          = module.keyvault.keyvault_id
  tags                 = var.tags
}
module "storage_account" {
  source               = "../../modules/storage-account"
  resource_group_name = module.resource_group.name
  location             = var.location
  storage_account_name = var.storage_account_name
  tags                 = var.tags
}
