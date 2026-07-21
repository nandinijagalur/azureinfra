terraform {
  backend "azurerm" {
    resource_group_name  = "rg_terraform_state"
    storage_account_name = "terraformstatesacac"
    container_name        = "tfstateterraformlandingzone"
    key                    = "dev.terraform.tfstate"
  }
}