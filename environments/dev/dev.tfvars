location             = "canadacentral"
resource_group_name  = "rg-landingzone-dev"
vnet_name             = "vnet-spoke-dev"
address_space         = ["10.1.0.0/16"]

subnets = {
  "snet-workload" = "10.1.1.0/24"
  "snet-aks"      = "10.1.2.0/24"
  "snet-db"       = "10.1.3.0/27"
}

tenant_id     = "15f213c8-2531-4889-9e2b-2a73b2afb2c6"
keyvault_name = "kv-lz-dev-nandini01"

tags = {
  project     = "secure-landing-zone"
  environment = "dev"
  managed_by  = "terraform"
  owner       = "nandini"
}
storage_account_name = "stlzdevnandini01"
allowed_locations  = ["canadacentral"]
required_tag_name = "environment"
sql_admin_object_id = "a1b2c3d4-5678-90ab-cdef-1234567890ab"   # replace with your actual Object ID