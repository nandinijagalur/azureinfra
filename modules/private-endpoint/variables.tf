variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "private_connection_resource_id" {
  description = "Resource ID of the target resource (e.g. Key Vault)"
  type        = string
}

variable "subresource_name" {
  description = "e.g. 'vault' for Key Vault"
  type        = string
}

variable "dns_zone_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}