resource_group_name = "rg-landingzone-hub"
location             = "canadacentral"
hub_vnet_name        = "vnet-hub"
hub_address_space    = ["10.0.0.0/16"]

subnets = {
  "snet-shared"        = "10.0.1.0/24"
  "AzureBastionSubnet" = "10.0.2.0/27"
}

tags = {
  project     = "secure-landing-zone"
  environment = "hub"
  managed_by  = "terraform"
  owner       = "nandini"
}
tenant_id     = "15f213c8-2531-4889-9e2b-2a73b2afb2c6"
keyvault_name = "kv-lz-hub-nandini01"

