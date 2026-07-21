resource "azurerm_key_vault" "this" {
  name                       = var.keyvault_name
  location                   = var.location
  resource_group_name       = var.resource_group_name
  tenant_id                  = var.tenant_id
  sku_name                   = "standard"

  soft_delete_retention_days = 7
  purge_protection_enabled   = true

   # Use Azure RBAC for access control instead of the legacy access-policy
  # model — required for azurerm_role_assignment (our rbac module) to work
  enable_rbac_authorization = true

  # Deny public network access by default — matches your original
  # guide's "TLS enforcement / secure by default" requirement
  public_network_access_enabled = true   # true for now (Free Tier, no Private Endpoint yet)
  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }

  tags = var.tags
}
