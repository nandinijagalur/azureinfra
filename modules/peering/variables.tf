variable "hub_vnet_name" {
  description = "Name of the hub virtual network"
  type        = string
}

variable "hub_vnet_id" {
  description = "Resource ID of the hub virtual network"
  type        = string
}

variable "hub_resource_group_name" {
  description = "Resource group where the hub VNet lives"
  type        = string
}

variable "spokes" {
  description = "Map of spoke name -> { vnet_name, vnet_id, resource_group_name }"
  type = map(object({
    vnet_name            = string
    vnet_id              = string
    resource_group_name = string
  }))
}