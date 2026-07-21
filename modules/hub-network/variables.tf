variable "resource_group_name" {
  description = "Name of the resource group where the hub VNet will be created"
  type        = string
}

variable "location" {
  description = "Azure region for the hub VNet"
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
  description = "Map of subnets to create in the hub. Key = subnet name, value = address prefix"
  type        = map(string)
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}