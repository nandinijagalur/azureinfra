variable "link_name" {
  type = string
}

variable "dns_zone_name" {
  type = string
}

variable "dns_zone_resource_group_name" {
  description = "Resource group where the DNS zone actually lives (the hub's RG)"
  type        = string
}

variable "vnet_id" {
  type = string
}
variable "tags" {
  type    = map(string)
  default = {}
}