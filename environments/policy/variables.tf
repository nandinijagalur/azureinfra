variable "allowed_locations" {
  description = "Regions allowed for resource deployment across the subscription"
  type        = list(string)
}

variable "required_tag_name" {
  description = "Tag key that must be present on all resources"
  type        = string
}