module "server_name" {
  source   = "../../general/name_conv"
  for_each = { for idx, sql in var.sql : idx => sql }
  env      = var.env
  prj_id   = var.prj_id
  workload = each.value.workload
  type     = "sql_server"
}

module "db_name" {
  source   = "../../general/name_conv"
  for_each = { for idx, db in local.dbs : "${db.server_key}.${db.db_key}" => db }
  env      = var.env
  prj_id   = var.prj_id
  workload = each.value.workload
  type     = "sql_db"
}

resource "random_password" "pwd" {
  for_each = { for idx, sql in var.sql : idx => sql }
  length   = 16
  keepers = {
    result = each.value.version
  }
}

module "kv_secret" {
  source   = "../kv_secret"
  for_each = { for idx, sql in var.sql : idx => sql }
  env      = var.env
  prj_id   = var.prj_id
  kv_secret = [{
    kv_id        = var.kv_id
    workload     = each.value.workload
    usage        = "${module.server_name[each.key].name}-pwd"
    value        = random_password.pwd[each.key].result
    content_type = "password"
  }]
}

resource "azurerm_mssql_server" "sql_server" {
  for_each                             = { for idx, sql in var.sql : idx => sql }
  name                                 = module.server_name[each.key].name
  tags                                 = each.value.tags
  resource_group_name                  = var.rg
  location                             = var.location
  version                              = each.value.version
  administrator_login                  = each.value.admin_user
  administrator_login_password         = random_password.pwd[each.key].result
  connection_policy                    = each.value.connection_policy
  outbound_network_restriction_enabled = each.value.is_outbound_restrict
  minimum_tls_version                  = "1.2"
  public_network_access_enabled        = false

  identity {
    type = "SystemAssigned"
  }

  azuread_administrator {
    login_username = each.value.ad_admin_user
    object_id      = each.value.ad_admin_object_id
    tenant_id      = var.tenant_id
  }
}

module "pe" {
  source       = "../private_endpoint"
  for_each     = { for idx, sql in var.sql : idx => sql }
  rg           = var.rg
  location     = var.location
  snet_id      = var.pe_snet_id
  res_name     = module.server_name[each.key].name
  res_type     = "azure_sql_server"
  res_id       = azurerm_mssql_server.sql_server[each.key].id
  subresources = ["sqlServer"]
}

resource "azurerm_mssql_database" "db" {
  for_each             = { for idx, db in local.dbs : "${db.server_key}.${db.db_key}" => db }
  name                 = module.db_name[each.key].name
  server_id            = azurerm_mssql_server.sql_server[each.value.server_key].id
  create_mode          = each.value.create_mode
  sku_name             = each.value.sku
  max_size_gb          = each.value.max_size_gb
  min_capacity         = each.value.min_capacity
  storage_account_type = each.value.sa_type
  license_type         = each.value.license

  dynamic "short_term_retention_policy" {
    for_each = each.value.short_term_backup_config != null ? [1] : []
    content {
      retention_days           = each.value.short_term_backup_config.retention_days
      backup_interval_in_hours = each.value.short_term_backup_config.backup_interval_in_hours
    }
  }

  dynamic "long_term_retention_policy" {
    for_each = each.value.long_term_backup_config != null ? [1] : []
    content {
      weekly_retention  = each.value.long_term_backup_config.weekly_retention
      monthly_retention = each.value.long_term_backup_config.monthly_retention
      yearly_retention  = each.value.long_term_backup_config.yearly_retention
      week_of_year      = each.value.long_term_backup_config.week_of_year
    }
  }
}
