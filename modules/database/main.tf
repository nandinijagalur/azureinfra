# ============================================================
# AZURE SQL SERVER — Entra ID (Azure AD) authentication ONLY
# No SQL login, no password, anywhere in this module.
# ============================================================

resource "azurerm_mssql_server" "this" {
  name                = var.sql_server_name
  resource_group_name = var.resource_group_name
  location            = var.location
  version             = "12.0"

  minimum_tls_version = "1.2"

  azuread_administrator {
    login_username              = var.admin_login_username
    object_id                   = var.admin_object_id
    azuread_authentication_only = true   # No SQL logins can ever exist on this server
  }

  public_network_access_enabled = true
  tags                           = var.tags
}

resource "azurerm_mssql_firewall_rule" "deny_all" {
  name             = "deny-all-by-default"
  server_id        = azurerm_mssql_server.this.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_mssql_virtual_network_rule" "aks_subnet" {
  name      = "allow-aks-subnet"
  server_id = azurerm_mssql_server.this.id
  subnet_id = var.aks_subnet_id
}

resource "azurerm_mssql_database" "this" {
  name      = var.database_name
  server_id = azurerm_mssql_server.this.id
  sku_name  = "GP_S_Gen5_2"
  min_capacity = 0.5   # minimum allowed for Gen5 serverless
  auto_pause_delay_in_minutes = 60
  tags                         = var.tags
}