variable "scope_id" {
  description = "Subscription or resource group ID to assign policies to"
  type        = string
}

variable "allowed_locations" {
  description = "List of Azure regions allowed for resource deployment"
  type        = list(string)
}

variable "required_tag_name" {
  description = "Tag key that must be present on all resources"
  type        = string
  default     = "environment"
}