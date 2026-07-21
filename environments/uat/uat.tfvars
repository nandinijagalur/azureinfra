location             = "canadacentral"
resource_group_name  = "rg-landingzone-uat"
vnet_name             = "vnet-spoke-uat"
address_space         = ["10.2.0.0/16"]

subnets = {
  "snet-workload" = "10.2.1.0/24"
}

tenant_id     = "15f213c8-2531-4889-9e2b-2a73b2afb2c6"
keyvault_name = "kv-lz-uat-nandini01"

tags = {
  project     = "secure-landing-zone"
  environment = "uat"
  managed_by  = "terraform"
  owner       = "nandini"
}
storage_account_name = "stlzuatnandini01"
allowed_locations  = ["canadacentral"]
required_tag_name = "environment"