# modules/aks/variables.tf

variable "cluster_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "dns_prefix" {
  type = string
}

variable "aks_subnet_id" {
  type = string
}

variable "acr_id" {
  type = string
}

variable "workload_identity_id" {
  description = "module.rbac.identity_id"
  type        = string
}

variable "workload_identity_name" {
  type = string
}

variable "k8s_namespace" {
  type    = string
  default = "default"
}

variable "k8s_service_account_name" {
  type    = string
  default = "app-sa"
}

variable "tags" {
  type    = map(string)
  default = {}
}