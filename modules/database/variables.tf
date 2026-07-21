variable "sql_server_name" {
  description = "Globally unique name for the Azure SQL logical server"
  type        = string
}

variable "database_name" {
  description = "Name of the database inside the server"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group to deploy into"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "admin_login_username" {
  description = "Display label for the Entra admin (your name or an admin group name)"
  type        = string
}

variable "admin_object_id" {
  description = "Entra ID Object ID granted SQL admin rights"
  type        = string
}

variable "aks_subnet_id" {
  description = "Subnet ID allowed to reach this database"
  type        = string
}

variable "tags" {
  description = "Tags applied to all resources in this module"
  type        = map(string)
  default     = {}
}

# NOTE: there is deliberately no admin_password / sql_admin_password
# variable in this file. This server uses Entra ID authentication only —
# a password variable would be dead configuration for a login mechanism
# that's disabled at the server level (azuread_authentication_only = true).