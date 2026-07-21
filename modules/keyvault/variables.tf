variable "resource_group_name" {
  description = "Resource group where this Key Vault will be created"
  type        = string
}

variable "location" {
  description = "Azure region for the Key Vault"
  type        = string
}

variable "keyvault_name" {
  description = "Globally unique name for the Key Vault"
  type        = string
}

variable "tenant_id" {
  description = "Azure AD tenant ID"
  type        = string
}

variable "tags" {
  description = "Tags applied to the Key Vault"
  type        = map(string)
  default     = {}
}