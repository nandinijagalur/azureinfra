# modules/acr/variables.tf
variable "acr_name" {
 
}
variable "resource_group_name" { type = string }
variable "location"            { type = string }
variable "tags"                { type = map(string) }