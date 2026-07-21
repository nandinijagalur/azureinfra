data "azurerm_subscription" "current" {}

module "policy" {
  source            = "../../modules/policy"
  scope_id           = data.azurerm_subscription.current.id   # ← changed from .subscription_id
  allowed_locations = var.allowed_locations
  required_tag_name = var.required_tag_name
}