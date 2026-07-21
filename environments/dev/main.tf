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
    dev = {
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
  identity_name        = "id-dev-app"
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

module "acr" {
  source              = "../../modules/acr"
  acr_name            = "acrlzdevnandini01"
  resource_group_name = module.resource_group.name
  location            = var.location
  tags                = var.tags
}

module "aks" {
  source                  = "../../modules/aks"
  cluster_name            = "aks-dev"
  resource_group_name     = module.resource_group.name
  location                = var.location
  dns_prefix              = "aksdev"
  aks_subnet_id           = module.spoke_network.spoke_subnet_ids["snet-aks"]
  acr_id                  = module.acr.acr_id
  workload_identity_id    = module.rbac.identity_id
  workload_identity_name  = "id-dev-app"
  tags                    = var.tags
}

module "database" {
  source               = "../../modules/database"
  sql_server_name      = "sql-lz-dev-nandini01"
  database_name        = "appdb-dev"
  resource_group_name  = module.resource_group.name
  location             = var.location
  admin_login_username = "nandini-admin"
  admin_object_id      = var.sql_admin_object_id
  aks_subnet_id = module.spoke_network.spoke_subnet_ids["snet-aks"]
  tags                 = var.tags
}