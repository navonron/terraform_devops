#terraform plan -var-file="qa.tfvars"
environment     = "dev"
project_id      = "pdaibi"
subscription_id = "1fd3090a-949b-4ab5-b266-8fbb6701f677"
location        = "westus2"
project_iap     = "25794"

#Need to Check these value
private_link_resource_group = "Azure-Product-Engineering-Analytics-Dev-Express-Route-Rg-WestUs2"
private_link_vnet_name      = "Azure-Analytics-Dev-Express-Route-Vnet-WestUs2"
#private_link_subnet_name    = "Azure-Analytics-Dev-Express-Route-Subnet2-WestUs2"
private_link_subnet_name    = "Azure-Analytics-Dev-Express-Route-Subnet-WestUs2"


entitlement_lookup = {
  "Design-PDA-Azure-Developers"            = "9cf993ae-cf96-4464-a2ae-2fa95236fe94"
  "sp_azure_data_platforms_pdaibi_dev"     = "80f32de0-09b1-4d99-be9b-cbc8d6339f0b"
  "ibi-daas-query-dev"                     = "c48ed1ca-c0ff-460c-9db3-20bcbad3c89e"
}
resource_group_access_mapping = {
  "Contributor" : [
    "Design-PDA-Azure-Developers",
    "sp_azure_data_platforms_pdaibi_dev"
  ],
  "Key Vault Administrator" : [
    "Design-PDA-Azure-Developers",
    "sp_azure_data_platforms_pdaibi_dev"
  ]
}
synapse_workspace_access_mapping = {
  # "Synapse Contributor" : [
  #   "Design-PDA-Azure-Developers"
  # ]
}
storage_account_access_mapping = {
  "Storage Blob Data Contributor" : [
    "Design-PDA-Azure-Developers",
    "sp_azure_data_platforms_pdaibi_dev",
    "ibi-daas-query-dev"
  ],
  "Storage Blob Delegator" : [
    "ibi-daas-query-dev"
  ]
}

# Databricks 
databricks_vnet_name                     = "Azure-Analytics-Dev-Express-Route-Vnet-Adb-WestUs2"
databricks_public_subnet_address_prefix  = "10.139.50.0/25"
databricks_private_subnet_address_prefix = "10.139.50.128/25"

platform_managed_service_principal = false

# App Service
service_plan_name_suffix                    = "windows"
service_plan_os_type                        = "Windows"
service_plan_sku_name                       = "P1v2"
web_app_runtime_version                     = "windows|dotnet|v6.0"
web_app_outbound_vnet_integration_subnet_id = "/subscriptions/1fd3090a-949b-4ab5-b266-8fbb6701f677/resourceGroups/Azure-Product-Engineering-Analytics-Dev-Express-Route-Rg-WestUs2/providers/Microsoft.Network/virtualNetworks/Azure-Analytics-Dev-Express-Route-Vnet-WestUs2/subnets/Azure-Analytics-Dev-Express-Route-Subnet2-WestUs2"
function_app_runtime_version                = "windows|DOTNET|v6.0"

sql_dbs = [
  {
    name_suffix          = "persistence",
    sku_name             = "Basic",
    storage_account_type = "Zone"
  },
  {
    name_suffix          = "efcore",
    sku_name             = "Basic",
    storage_account_type = "Zone"
  },
  {
    name_suffix = "report",
    sku_name    = "Basic"
}]

add_private_dns_forwarding = false