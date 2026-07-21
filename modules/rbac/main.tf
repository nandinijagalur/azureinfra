resource "azurerm_user_assigned_identity" "this" {
  name                = var.identity_name
  resource_group_name = var.resource_group_name
  location             = var.location
  tags                 = var.tags
}

resource "azurerm_role_assignment" "keyvault_access" {
  scope                = var.keyvault_id
  role_definition_name = var.role_name
  principal_id         = azurerm_user_assigned_identity.this.principal_id
}