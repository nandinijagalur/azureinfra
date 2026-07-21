variable "location" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "resource_group_name" {
  type = string
}

variable "vnet_name" {
  type = string
}

variable "address_space" {
  type = list(string)
}

variable "subnets" {
  type = map(string)
}

variable "tenant_id" {
  type = string
}

variable "keyvault_name" {
  type = string
}
variable "storage_account_name" {
  type = string
}
variable "allowed_locations" {
  description = "Regions allowed for resources in this resource group"
  type        = list(string)
}

variable "required_tag_name" {
  description = "Tag key that must be present on resources in this resource group"
  type        = string
  default     = "environment"
}


variable "sql_admin_object_id" {
  description = "Entra ID Object ID of the SQL admin (your user, or an admin group)"
  type        = string
}