resource "azurerm_storage_account" "this" {
  name                     = var.storage_account_name
  resource_group_name     = var.resource_group_name
  location                 = var.location
  account_tier              = "Standard"
  account_replication_type = "LRS"

  # Matches your original guide's "deny public IP on Storage Accounts"
  # requirement — also what the custom Azure Policy checks for
  public_network_access_enabled = false

  # Belt-and-suspenders: blocks anonymous/public blob access even if
  # a container is misconfigured later
  allow_nested_items_to_be_public = false

  min_tls_version = "TLS1_2"

  tags = var.tags
}

#resource "azurerm_storage_container" "this" {
 # name                  = var.container_name
  #storage_account_name = azurerm_storage_account.this.name
  #container_access_type = "private"
#}