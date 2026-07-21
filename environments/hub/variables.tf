variable "resource_group_name" {
  description = "Name of the hub resource group"
  type        = string
}

variable "location" {
  description = "Azure region for all hub resources"
  type        = string
}

variable "hub_vnet_name" {
  description = "Name of the hub virtual network"
  type        = string
}

variable "hub_address_space" {
  description = "Address space for the hub VNet"
  type        = list(string)
}

variable "subnets" {
  description = "Map of subnet name -> address prefix for the hub"
  type        = map(string)
}

variable "tags" {
  description = "Tags applied to all hub resources"
  type        = map(string)
  default     = {}
}
variable "tenant_id" {
  type = string
}

variable "keyvault_name" {
  type = string
}