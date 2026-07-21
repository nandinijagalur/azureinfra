# modules/acr/main.tf
resource "azurerm_container_registry" "this" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Basic"   # cheapest SKU (~$0.17/day) — no free tier exists for ACR
  admin_enabled       = false     # never use admin credentials — AKS pulls via managed identity

  tags = var.tags
}