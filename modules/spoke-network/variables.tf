variable "resource_group_name" {
  description = "Resource group where this spoke VNet will be created"
  type        = string
}

variable "location" {
  description = "Azure region for the spoke VNet"
  type        = string
}

variable "spoke_vnet_name" {
  description = "Name of the spoke virtual network"
  type        = string
}

variable "spoke_address_space" {
  description = "Address space for the spoke VNet"
  type        = list(string)
}

variable "subnets" {
  description = "Map of subnet name -> address prefix for this spoke"
  type        = map(string)
}

variable "tags" {
  description = "Tags applied to all resources in this spoke"
  type        = map(string)
  default     = {}
}