variable "resource_group_name" {
  type = string
}

variable "zone_name" {
  description = "Private DNS zone name, e.g. privatelink.vaultcore.azure.net"
  type        = string
}

variable "hub_vnet_id" {
  description = "Hub VNet ID — linked to the zone so hub-side resolution works too"
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}