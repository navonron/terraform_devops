module "name" {
  source     = "../../general/name_conv"
  for_each   = { for idx, cosmos in var.cosmosdb : idx => cosmos }
  env        = var.env
  prj_id     = var.prj_id
  workload   = each.value.workload
  cosmos_api = lower(each.value.kind)
  type       = "cosmosdb"
}

module "kv_key" {
  source   = "../kv_key"
  for_each = { for idx, cosmos in var.cosmosdb : idx => cosmos }
  env      = var.env
  prj_id   = var.prj_id
  kv_key = [{
    kv_id    = var.kv_id
    usage    = "${module.name[each.key].name}-cmk"
    type     = "RSA"
    opts     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
    workload = each.value.workload
    rotation = {
      auto_rotate_after = "P1Y"
    }
  }]
}


resource "azurerm_cosmosdb_account" "cosmosdb" {
  for_each                           = { for idx, cosmos in var.cosmosdb : idx => cosmos }
  name                               = module.name[each.key].name
  resource_group_name                = var.rg
  location                           = var.location
  tags                               = each.value.tags
  kind                               = each.value.kind
  mongo_server_version               = each.value.mongo_version
  create_mode                        = each.value.backup.type == "Continuous" ? each.value.create_mode : null
  key_vault_key_id                   = module.kv_key[0].versionless_id[each.key]
  enable_multiple_write_locations    = each.value.is_multi_write
  enable_automatic_failover          = each.value.is_auto_fail
  local_authentication_disabled      = each.value.is_local_auth
  ip_range_filter                    = each.value.allow_ips
  is_virtual_network_filter_enabled  = length(each.value.allow_snets) > 0
  offer_type                         = "Standard"
  access_key_metadata_writes_enabled = false
  public_network_access_enabled      = false

  identity {
    type = "SystemAssigned"
  }

  consistency_policy {
    consistency_level       = each.value.consistency.level
    max_interval_in_seconds = each.value.consistency.level == "BoundedStaleness" ? each.value.consistency.max_interval_in_seconds : null
    max_staleness_prefix    = each.value.consistency.level == "BoundedStaleness" ? each.value.consistency.max_staleness_prefix : null
  }

  geo_location {
    location          = each.value.geo_location == null ? var.location : each.value.geo_location.primary == null ? var.location : each.value.geo_location.primary.location
    failover_priority = 0
    zone_redundant    = each.value.geo_location == null ? false : each.value.geo_location.primary == null ? false : each.value.geo_location.primary.zone_redundant
  }

  dynamic "geo_location" {
    for_each = each.value.geo_location != null ? each.value.geo_location.secondary != null ? [1] : [] : []
    content {
      location          = each.value.geo_location.secondary.location
      failover_priority = 1
      zone_redundant    = each.value.geo_location.secondary.zone_redundant
    }
  }

  dynamic "backup" {
    for_each = each.value.backup != null ? [1] : []
    content {
      type                = each.value.backup.type
      interval_in_minutes = each.value.backup.interval_in_minutes
      retention_in_hours  = each.value.backup.retention_in_hours
      storage_redundancy  = each.value.backup.storage_redundancy
    }
  }

  dynamic "capacity" {
    for_each = each.value.throughput_limit != null ? [1] : []
    content {
      total_throughput_limit = each.value.throughput_limit
    }
  }

  dynamic "capabilities" {
    for_each = each.value.capabilities
    content {
      name = capabilities.value
    }
  }

  dynamic "virtual_network_rule" {
    for_each = each.value.allow_snets
    content {
      id = virtual_network_rule.value
    }
  }
}

module "rbac" {
  source   = "../rbac"
  for_each = { for idx, rbac in local.rbac : "${rbac.svc_key}.${rbac.rbac_key}" => rbac }
  rbac = [{
    scope   = azurerm_cosmosdb_account.cosmosdb[each.value.svc_key].id
    role    = each.value.role
    members = each.value.members
  }]
}

module "pe" {
  source       = "../private_endpoint"
  for_each     = { for idx, sub in local.subresources : "${sub.svc_key}.${sub.sub_key}" => sub }
  rg           = var.rg
  location     = var.location
  snet_id      = var.pe_snet_id
  res_name     = "${module.name[each.value.svc_key].name}.${each.value.subresource}"
  res_type     = "cosmos_db"
  res_id       = azurerm_cosmosdb_account.cosmosdb[each.value.svc_key].id
  subresources = [each.value.subresource]
}
