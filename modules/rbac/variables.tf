variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "identity_name" {
  type = string
}

variable "keyvault_id" {
  description = "Resource ID of the Key Vault this identity should access"
  type        = string
}

variable "role_name" {
  description = "RBAC role to assign on the Key Vault"
  type        = string
  default     = "Key Vault Secrets User"
}

variable "tags" {
  type    = map(string)
  default = {}
}