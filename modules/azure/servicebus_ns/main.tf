module "name" {
  source   = "../../general/name_conv"
  for_each = { for idx, ns in var.servicebus_ns : idx => ns }
  env      = var.env
  prj_id   = var.prj_id
  workload = each.value.workload
  type     = "servicebus_ns"
}

module "kv_key" {
  source   = "../kv_key"
  for_each = { for idx, ns in var.servicebus_ns : idx => ns }
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

module "mid" {
  source   = "../mid"
  for_each = { for idx, ns in var.servicebus_ns : idx => ns }
  env      = var.env
  prj_id   = var.prj_id
  location = var.location
  rg       = var.rg
  workload = each.value.workload
}

module "mid_rbac" {
  source   = "../rbac"
  for_each = { for idx, ns in var.servicebus_ns : idx => ns }
  rbac = [{
    scope   = var.kv_id
    role    = "Key Vault Administrator"
    members = [module.mid[each.key].principal_id]
  }]
}

resource "azurerm_servicebus_namespace" "servicebus_ns" {
  for_each                      = { for idx, ns in var.servicebus_ns : idx => ns }
  name                          = module.name[each.key].name
  resource_group_name           = var.rg
  location                      = var.location
  tags                          = each.value.tags
  sku                           = each.value.sku
  capacity                      = each.value.capacity
  local_auth_enabled            = each.value.is_local_auth
  zone_redundant                = each.value.is_zrs
  minimum_tls_version           = "1.2"
  public_network_access_enabled = false

  identity {
    type = "UserAssigned"
    identity_ids = [module.mid[each.key].id]
  }

  customer_managed_key {
    key_vault_key_id                  = module.kv_key[0].versionless_id[each.key]
    identity_id                       = module.mid[each.key].id
    infrastructure_encryption_enabled = true
  }

  dynamic "network_rule_set" {
    for_each = each.value.networking != null ? [1] : []
    content {
      default_action                = "Deny"
      public_network_access_enabled = false
      trusted_services_allowed      = each.value.networking.trusted_service_access
      ip_rules                      = each.value.networking.allow_ips

      dynamic "network_rules" {
        for_each = each.value.networking.allow_snets
        content {
          subnet_id = each.value.networking.allow_snets
        }
      }
    }
  }
}

resource "azurerm_servicebus_queue" "queue" {
  for_each            = { for idx, queue in local.queues : "${queue.ns_key}.${queue.queue_key}" => queue }
  name                = each.value.name
  namespace_id        = azurerm_servicebus_namespace.servicebus_ns[each.value.ns_key].id
  enable_partitioning = each.value.is_partitioning
}

resource "azurerm_servicebus_topic" "topic" {
  for_each            = { for idx, topic in local.topics : "${topic.ns_key}.${topic.topic_key}" => topic }
  name                = each.value.name
  namespace_id        = azurerm_servicebus_namespace.servicebus_ns[each.value.ns_key].id
  enable_partitioning = each.value.is_partitioning
}

resource "azurerm_servicebus_subscription" "subscription" {
  for_each           = { for idx, sub in local.subscriptions : "${sub.ns_key}.${sub.topic_key}.${sub.sub_key}" => sub }
  name               = each.value.name
  topic_id           = azurerm_servicebus_topic.topic["${each.value.ns_key}.${each.value.topic_key}"].id
  max_delivery_count = each.value.max_delivery_count
}

module "rbac" {
  source   = "../rbac"
  for_each = { for idx, rbac in local.rbac : "${rbac.svc_key}.${rbac.rbac_key}" => rbac }
  rbac = [{
    scope   = azurerm_servicebus_namespace.servicebus_ns[each.value.svc_key].id
    role    = each.value.role
    members = each.value.members
  }]
}

module "pe" {
  source       = "../private_endpoint"
  for_each     = { for idx, ns in var.servicebus_ns : idx => ns }
  rg           = var.rg
  location     = var.location
  snet_id      = var.pe_snet_id
  res_name     = module.name[each.key].name
  res_type     = "servicebus_namespace"
  res_id       = azurerm_servicebus_namespace.servicebus_ns[each.key].id
  subresources = ["namespace"]
}
