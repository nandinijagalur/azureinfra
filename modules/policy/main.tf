# ── Built-in: Allowed locations ──
# Denies creating any resource outside the specified region(s)
resource "azurerm_subscription_policy_assignment" "allowed_locations" {
  name                 = "allowed-locations"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c"
  subscription_id      = var.scope_id
  display_name         = "Allowed locations"

  parameters = jsonencode({
    listOfAllowedLocations = { value = var.allowed_locations }
  })
}

# ── Built-in: Require a specific tag ──
# Denies creating any resource that's missing the required tag
resource "azurerm_subscription_policy_assignment" "require_tag" {
  name                 = "require-environment-tag"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/871b6d14-10aa-478d-b590-94f262ecfa99"
  subscription_id      = var.scope_id
  display_name         = "Require environment tag"

  parameters = jsonencode({
    tagName = { value = var.required_tag_name }
  })
}

# ── Built-in: Key Vault should have soft-delete enabled ──
# (Audit effect — Azure's built-in version reports non-compliance
# rather than blocking, since soft-delete can't always be enforced at
# creation time depending on vault configuration history)
resource "azurerm_subscription_policy_assignment" "keyvault_soft_delete" {
  name                 = "keyvault-soft-delete-audit"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/1e66c121-a66a-4b1f-9b83-0fd99bf0fc2d"
  subscription_id      = var.scope_id
  display_name         = "Key Vault should have soft delete enabled"
}

# ── Custom: Deny public network access on Storage Accounts ──
resource "azurerm_policy_definition" "deny_public_storage" {
  name         = "deny-public-storage-network-access"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Deny public network access on Storage Accounts"
  description  = "Blocks creation or update of Storage Accounts with public network access enabled"

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field  = "type"
          equals = "Microsoft.Storage/storageAccounts"
        },
        {
          field    = "Microsoft.Storage/storageAccounts/publicNetworkAccess"
          notEquals = "Disabled"
        }
      ]
    }
    then = {
      effect = "deny"
    }
  })
}

resource "azurerm_subscription_policy_assignment" "deny_public_storage" {
  name                 = "deny-public-storage"
  policy_definition_id = azurerm_policy_definition.deny_public_storage.id
  subscription_id      = var.scope_id
  display_name         = "Deny public storage account access"
}