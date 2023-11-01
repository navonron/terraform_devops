module "name" {
  for_each = { for idx, pool in var.synapse_sql_pool : idx => pool }
  source   = "../../general/name_conv"
  env      = var.env
  prj_id   = var.prj_id
  workload = each.value.workload
  type     = "synapse_sql_pool"
}

resource "azurerm_synapse_sql_pool" "pool" {
  for_each                  = { for idx, pool in var.synapse_sql_pool : idx => pool }
  name                      = module.name[each.key].name
  tags                      = each.value.tags
  synapse_workspace_id      = var.synapse_id
  sku_name                  = each.value.sku
  create_mode               = each.value.create_mode
  collation                 = each.value.create_mode == "Default" ? each.value.collation : null
  data_encrypted            = each.value.data_encrypt
  geo_backup_policy_enabled = each.value.is_geo_backup
  recovery_database_id      = each.value.create_mode == "Recovery" ? each.value.recovery_db_id : null

  dynamic "restore" {
    for_each = each.value.create_mode == "PointInTimeRestore" && each.value.restore != null ? [1] : []
    content {
      source_database_id = each.value.restore.db_id
      point_in_time      = each.value.restore.point_in_time
    }
  }
}
