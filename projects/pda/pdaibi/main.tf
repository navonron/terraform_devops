### RESOURCE GROUPS ####
module "rg" {
  source   = "../../../modules/azure/resource_group"
  env      = var.env
  location = var.location
  prj_id   = var.prj_id
  tags     = var.tags
  rg       = var.rg
}

### APP SERVICE PLAN ###
module "asp" {
  source   = "../../../modules/azure/app_service_plan"
  env      = var.env
  location = var.location
  prj_id   = var.prj_id
  rg       = module.rg.name[0]
  asp      = var.asp
}

### STORAGE ACCOUNT ###
module "sa" {
  source     = "../../../modules/azure/storage_account"
  env        = var.env
  prj_id     = var.prj_id
  location   = var.location
  rg         = module.rg.name[0]
  pe_snet_id = var.pe_snet
  sa         = var.sa
}

module "intel_a_record_sa" {
  providers = { azurerm = azurerm.shared }
  source    = "../../../modules/azure/a_record"
  for_each  = { for idx, sub in local.subresources : "${sub.svc_key}.${sub.sub_key}" => sub }
  res_name  = "${module.sa.name[each.value.svc_key]}.${each.value.subresource}"
  zone_name = var.custom_fqdn
  zone_rg   = var.zone_rg
  ttl       = var.ttl
  ip        = each.value.ip
}

### WINDOWS WEB APP ###
module "windows_web_app" {
  source                   = "../../../modules/azure/windows_web_app"
  env                      = var.env
  location                 = var.location
  prj_id                   = var.prj_id
  rg                       = module.rg.name[0]
  asp_id                   = module.asp.id[0]
  vnet_integration_snet_id = var.vnet_integration_snet_id
  pe_snet_id               = var.pe_snet
  windows_web_app          = var.windows_web_app
}

### WINDOWS FUNCTION APP ###
module "windows_func" {
  source                   = "../../../modules/azure/windows_func"
  env                      = var.env
  location                 = var.location
  prj_id                   = var.prj_id
  asp_id                   = module.asp.id[0]
  rg                       = module.rg.name[0]
  vnet_integration_snet_id = var.vnet_integration_snet_id
  pe_snet_id               = var.pe_snet
  sa_name                  = module.sa.name[1]
  sa_primary_access_key    = module.sa.primary_access_key[1]
  windows_func             = var.windows_func
}

### EVENT HUB NAMESPACE ###
module "eventhub_ns" {
  source      = "../../../modules/azure/eventhub_ns"
  env         = var.env
  prj_id      = var.prj_id
  location    = var.location
  rg          = module.rg.name[0]
  pe_snet_id  = var.pe_snet
  eventhub_ns = var.eventhub_ns
}

### KEY VAULT ###
module "kv" {
  providers  = { azurerm = azurerm.dev }
  source     = "../../../modules/azure/key_vault"
  env        = var.env
  prj_id     = var.prj_id
  location   = var.location
  rg         = module.rg.name[0]
  pe_snet_id = var.pe_snet
  tenant_id  = var.tenant_id
  kv         = var.kv
}

### SQL ###
module "sql" {
  source     = "../../../modules/azure/sql"
  env        = var.env
  prj_id     = var.prj_id
  location   = var.location
  rg         = module.rg.name[0]
  pe_snet_id = var.pe_snet
  tenant_id  = var.tenant_id
  kv_id      = module.kv.id[0]
  sql        = var.sql
}

### SERVICEBUS NAMESPACE ###
module "servicebus_ns" {
  source        = "../../../modules/azure/servicebus_ns"
  env           = var.env
  prj_id        = var.prj_id
  location      = var.location
  rg            = module.rg.name[0]
  pe_snet_id    = var.pe_snet
  kv_id         = module.kv.id[0]
  servicebus_ns = var.servicebus_ns
}

##### ADD EXIST CONFIG #####
### DATA FACTORY ###
module "adf" {
  source     = "../../../modules/azure/data_factory"
  env        = var.env
  prj_id     = var.prj_id
  location   = var.location
  rg         = module.rg.name[0]
  pe_snet_id = var.pe_snet
  link_kv_id = module.kv.id[0]
  adf = [{
    global_params = [
      {
        name  = "environment"
        type  = "String"
        value = var.env
      },
      {
        name  = "ibi_data_lake_storage_url"
        type  = "String"
        value = module.sa.fqdn[0]
      },
      {
        name  = "storage_account_name"
        type  = "String"
        value = module.sa.name[0]
      },
      {
        name  = "daas_api_token_url"
        type  = "String"
        value = "https://ibi-daas-api-dev.intel.com/v1/auth/token"
      },
      {
        name  = "daas_api_base_url"
        type  = "String"
        value = "https://ibi-daas-api-dev.intel.com"
      },
      {
        name  = "databricks_workspace_url"
        type  = "String"
        value = "https://${module.databricks.fqdn[0]}"
      },
      {
        name  = "databricks_2_workspace_url"
        type  = "String"
        value = "https://${module.databricks.fqdn[0]}"
      },
      {
        name  = "ibi_databricks_service_url"
        type  = "String"
        value = "https://ibi-daas-api-dev.intel.com/databricks"
      },
      {
        name  = "azure_key_vault_url"
        type  = "String"
        value = module.kv.uri[0]
      },
      {
        name  = "ibi_adf_handler_service_url"
        type  = "String"
        value = module.windows_web_app.fqdn[0]
      },
      {
        name  = "collection_helper_service_url"
        type  = "String"
        value = module.windows_web_app.fqdn[1]
      },
      {
        name  = "ibi_arm_service_url"
        type  = "String"
        value = module.windows_func.fqdn[0]
      },
      {
        name  = "ibi_storage_service_url"
        type  = "String"
        value = module.windows_web_app.fqdn[6]
      },

      {
        name  = "ibi_db_service_url"
        type  = "String"
        value = module.windows_web_app.fqdn[2]
      },
      {
        name  = "ibi_metadata_service_url"
        type  = "String"
        value = module.windows_web_app.fqdn[3]
      },
      {
        name  = "ibi_collectionflow_service_url"
        type  = "String"
        value = module.windows_func.fqdn[1]
      }
    ]
  }]
}

### EVENTGRID SYSTEM TOPIC ###
module "eventgrid_sys_topic" {
  source              = "../../../modules/azure/eventgrid_sys_topic"
  env                 = var.env
  prj_id              = var.prj_id
  location            = var.location
  rg                  = module.rg.name[0]
  sa_id               = module.sa.id[0]
  eventgrid_sys_topic = var.eventgrid_sys_topic
}

### COSMOS DB ACCOUNT ###
module "cosmosdb_account" {
  source     = "../../../modules/azure/cosmosdb_account"
  env        = var.env
  prj_id     = var.prj_id
  location   = var.location
  rg         = module.rg.name[0]
  pe_snet_id = var.pe_snet
  kv_id      = module.kv.id[0]
  cosmosdb   = var.cosmosdb
}

module "intel_a_record_cosmosdb" {
  providers = { azurerm = azurerm.shared }
  source    = "../../../modules/azure/a_record"
  for_each  = { for idx, cosmosdb in var.cosmosdb[0].subresources : idx => cosmosdb }
  res_name  = "${module.cosmosdb_account.name[0]}.${lower(each.value)}"
  zone_name = var.custom_fqdn
  zone_rg   = var.zone_rg
  ttl       = var.ttl
  ip        = module.cosmosdb_account.ip[each.key]
}

### DATABRICKS ###
module "databricks" {
  source     = "../../../modules/azure/databricks"
  env        = var.env
  prj_id     = var.prj_id
  location   = var.location
  rg         = module.rg.name[0]
  pe_snet_id = var.pe_snet
  databricks = var.databricks
}

### SYNAPSE ###
module "synapse" {
  source     = "../../../modules/azure/synapse"
  env        = var.env
  prj_id     = var.prj_id
  location   = var.location
  rg         = module.rg.name[0]
  pe_snet_id = var.pe_snet
  tenant_id  = var.tenant_id
  kv_id      = module.kv.id[0]
  synapse = [merge({
    mpe = [
      {
        target_name        = "${module.sa.name[0]}-blob"
        target_id          = module.sa.id[0]
        target_subresource = "blob"
      },
      {
        target_name        = "${module.sa.name[0]}-dfs"
        target_id          = module.sa.id[0]
        target_subresource = "dfs"
      }
    ]
  }, var.synapse[0])]
}

module "intel_a_record_synapse" {
  providers = { azurerm = azurerm.shared }
  source    = "../../../modules/azure/a_record"
  for_each  = { for idx, synapse in var.synapse[0].subresources : idx => synapse }
  res_name  = "${module.synapse.name[0]}.${lower(each.value)}"
  zone_name = var.custom_fqdn
  zone_rg   = var.zone_rg
  ttl       = var.ttl
  ip        = module.synapse.ip[0]
}

module "intel_a_record_synapse_sa" {
  providers = { azurerm = azurerm.shared }
  source    = "../../../modules/azure/a_record"
  for_each  = { for idx, sub in var.synapse[0].sa.subresources : idx => sub }
  res_name  = "${module.synapse.sa_name[0]}.${each.value}"
  zone_name = var.custom_fqdn
  zone_rg   = var.zone_rg
  ttl       = var.ttl
  ip        = module.synapse.sa_ip[each.key]
}
##### ADD EXIST CONFIG #####

module "a_record" {
  providers = { azurerm = azurerm.shared }
  source    = "../../../modules/azure/a_record"
  for_each  = { for idx, ip in local.resources_ips : idx => ip }
  res_name  = local.resources_names[each.key]
  zone_name = var.custom_fqdn
  zone_rg   = var.zone_rg
  ttl       = var.ttl
  ip        = each.value
}
