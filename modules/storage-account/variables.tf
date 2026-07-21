variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "storage_account_name" {
  description = "Globally unique storage account name (lowercase, no hyphens, 3-24 chars)"
  type        = string
}

variable "container_name" {
  description = "Name of the blob container to create inside this storage account"
  type        = string
  default     = "data"
}

variable "tags" {
  type    = map(string)
  default = {}
}