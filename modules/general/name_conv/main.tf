locals {
  # A default function to return a generic name
  default_name = "${var.type}-${var.env}"

  # A function to generate the name for a webapp
  rg_name                  = var.workload != "" ? "rg-${var.prj_id}-${var.workload}-${var.env}" : "rg-${var.prj_id}-${var.env}"
  asp_name                 = var.workload != "" ? "asp-${var.prj_id}-${lower(var.asp_os)}-${var.workload}-${var.env}" : "asp-${var.prj_id}-${lower(var.asp_os)}-${var.env}"
  app_name                 = "app-${var.prj_id}-${var.workload}-${var.env}"
  func_name                = "func-${var.prj_id}-${var.workload}-${var.env}"
  sa_name                  = "sa${var.prj_id}${var.workload}${var.env}"
  event_hub_ns_name        = var.workload != "" ? "evhns-${var.prj_id}-${var.workload}-${var.env}" : "evhns-${var.prj_id}-${var.env}"
  sql_server_name          = var.workload != "" ? "sql-${var.prj_id}-${var.workload}-${var.env}" : "sql-${var.prj_id}-${var.env}"
  sql_db_name              = var.workload != "" ? "sqldb-${var.prj_id}-${var.workload}-${var.env}" : "sqldb-${var.prj_id}-${var.env}"
  servicebus_ns_name       = var.workload != "" ? "sbns-${var.prj_id}-${var.workload}-${var.env}" : "sbns-${var.prj_id}-${var.env}"
  kv_name                  = var.workload != "" ? "kv-${var.prj_id}-${var.workload}-${var.env}" : "kv-${var.prj_id}-${var.env}"
  kv_secret_name           = var.workload != "" ? "secret-${var.workload}-${var.usage}" : "secret-${var.usage}"
  kv_key_name              = var.workload != "" ? "key-${var.workload}-${var.usage}" : "key-${var.usage}"
  adf_name                 = var.workload != "" ? "adf-${var.prj_id}-${var.workload}-${var.env}" : "adf-${var.prj_id}-${var.env}"
  eventgrid_sys_topic_name = var.workload != "" ? "egst-${var.prj_id}-${var.workload}-${var.env}" : "egst-${var.prj_id}-${var.env}"
  cosmosdb_name            = var.workload != "" ? "cosmos-${var.cosmos_api}-${var.prj_id}-${var.workload}-${var.env}" : "cosmos-${var.cosmos_api}-${var.prj_id}-${var.env}"
  databricks_name          = var.workload != "" ? "adb-${var.prj_id}-${var.workload}-${var.env}" : "adb-${var.prj_id}-${var.env}"
  snet_name                = "snet-${var.is_public == true ? "public" : "private"}-${var.prj_id}-${var.workload}-${var.env}"
  nsg_name                 = "nsg-${var.prj_id}-${var.workload}-${var.env}"
  synapse_name             = var.workload != "" ? "synw-${var.prj_id}-${var.workload}-${var.env}" : "synw-${var.prj_id}-${var.env}"
  synapse_link_hub_name    = "synlh${var.prj_id}${var.env}"
  synapse_sql_pool_name    = "syndp${var.prj_id}${var.workload}${var.env}"
  mid_name                 = var.workload != "" ? "mid-${var.prj_id}-${var.workload}-${var.env}" : "mid-${var.prj_id}-${var.env}"
  name                     = lookup(local.name_functions, var.type, local.default_name)
}
