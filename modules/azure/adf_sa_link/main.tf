module "rbac" {
  source   = "../rbac"
  for_each = { for idx, link in var.link : idx => link }
  rbac = [
    {
      scope         = each.value.kv_id
      role          = "Key Vault Secrets User"
      principal_ids = [each.value.adf_principal_id]
    },
    {
      scope         = each.value.sa_id
      role          = "Storage Blob Data Contributor"
      principal_ids = [each.value.adf_principal_id]
    }
  ]
}

module "kv_secret" {
  source   = "../kv_secret"
  for_each = { for idx, link in var.link : idx => link }
  env      = var.env
  prj_id   = var.prj_id
  kv_secret = [{
    kv_id        = each.value.kv_id
    usage        = "${each.value.name}-sa-key"
    value        = each.value.key
    content_type = "password"
  }]
}

resource "azurerm_data_factory_linked_service_azure_blob_storage" "link_sa" {
  for_each        = { for idx, link in var.link : idx => link }
  name            = "link_${each.value.name}"
  data_factory_id = var.adf_id
  tenant_id       = var.tenant_id
  service_endpoint = "https://${each.value.name}.blob.core.windows.net"

  service_principal_linked_key_vault_key {
    linked_service_name = var.kv_link_name
    secret_name         = module.kv_secret[each.key].name
  }
}
























# resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "link_data_lake" {
#   for_each            = { for idx, link in local.link_svc : "${link.adf_key}.${link.link_key}" => link }
#   name                = each.value.name
#   data_factory_id     = azurerm_data_factory.adf[each.value.adf_key].id
#   storage_account_key = each.value.data_lake.sa_key
#   tenant              = var.tenant_id
#   url                 = each.value.data_lake.uri
# }

# resource "azurerm_data_factory_linked_service_azure_databricks" "link_databricks" {
#   for_each        = { for idx, link in local.link_svc : "${link.adf_key}.${link.link_key}" => link }
#   name            = each.value.name
#   data_factory_id = azurerm_data_factory.adf[each.value.adf_key].id
#   adb_domain      = "https://${each.value.adb.uri}"
#   existing_cluster_id = each.value.adb.id

#   key_vault_password {
#     linked_service_name = azurerm_data_factory_linked_service_key_vault.link_kv[each.value.adf_key].name
#     secret_name         = "databricks_access_token-${module.name[each.value.adf_key].name}"
#   }

#   dynamic "instance_pool" {
#     for_each = each.value.adb.uri == null ? [1] : []
#     content {
#       instance_pool_id      = each.value.adb.instance_pool_id
#       cluster_version       = each.value.adb.cluster_version
#       min_number_of_workers = each.value.adb.min_workers_num
#       max_number_of_workers = each.value.adb.max_workers_num
#     }
#   }
# }

# resource "azurerm_data_factory_linked_service_azure_function" "link_func" {
#   for_each        = { for idx, link in local.link_svc : "${link.adf_key}.${link.link_key}" => link }
#   name            = each.value.name
#   data_factory_id =  azurerm_data_factory.adf[each.value.adf_key].id
#   url             = "https://${each.value.func.uri}"
#   key             = each.value.func.key
# }

# resource "azurerm_data_factory_linked_service_synapse" "link_synapse" {
#   #   for_each        = { for idx, link in local.link_svc : "${link.adf_key}.${link.link_key}" => link }
#   name            = each.value.name
#   data_factory_id = azurerm_data_factory.adf[each.value.adf_key].id
#   connection_string = each.value.synapse.connct_str

#   key_vault_password {
#     linked_service_name = azurerm_data_factory_linked_service_key_vault.link_kv[each.value.adf_key].name
#     secret_name         = "synapse_access_token-${module.name[each.value.adf_key].name}"
#   }
# }

# resource "azurerm_data_factory_linked_service_mysql" "example" {
#   name              = "example"
#   data_factory_id   = azurerm_data_factory.example.id
#   connection_string = "Server=test;Port=3306;Database=test;User=test;SSLMode=1;UseSystemTrustStore=0;Password=test"
# }
