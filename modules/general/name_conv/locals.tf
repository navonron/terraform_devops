locals {
  # A map of functions to generate the name based on the type
  name_functions = {
    rg                  = local.rg_name
    asp                 = local.asp_name
    app                 = local.app_name
    func                = local.func_name
    sa                  = local.sa_name
    event_hub_ns        = local.event_hub_ns_name
    sql_server          = local.sql_server_name
    sql_db              = local.sql_db_name
    servicebus_ns       = local.servicebus_ns_name
    kv                  = local.kv_name
    kv_secret           = local.kv_secret_name
    kv_key              = local.kv_key_name
    adf                 = local.adf_name
    eventgrid_sys_topic = local.eventgrid_sys_topic_name
    cosmosdb            = local.cosmosdb_name
    databricks          = local.databricks_name
    snet                = local.snet_name
    nsg                 = local.nsg_name
    synapse             = local.synapse_name
    synapse_link_hub    = local.synapse_link_hub_name
    synapse_sql_pool    = local.synapse_sql_pool_name
    mid                 = local.mid_name
  }
}
