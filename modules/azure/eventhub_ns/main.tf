module "name" {
  source   = "../../general/name_conv"
  for_each = { for idx, ns in var.eventhub_ns : idx => ns }
  env      = var.env
  prj_id   = var.prj_id
  workload = each.value.workload
  type     = "event_hub_ns"
}

resource "azurerm_eventhub_namespace" "eventhub_ns" {
  for_each                      = { for idx, ns in var.eventhub_ns : idx => ns }
  name                          = module.name[each.key].name
  resource_group_name           = var.rg
  location                      = var.location
  tags                          = each.value.tags
  sku                           = each.value.sku
  capacity                      = each.value.capacity
  auto_inflate_enabled          = each.value.is_auto_inflate
  maximum_throughput_units      = each.value.is_auto_inflate ? each.value.max_throughput : null
  zone_redundant                = each.value.is_zrs
  local_authentication_enabled  = each.value.is_local_auth
  public_network_access_enabled = false

  identity {
    type = "SystemAssigned"
  }

  network_rulesets {
    default_action                 = "Deny"
    public_network_access_enabled  = false
    trusted_service_access_enabled = true
  }

}

resource "azurerm_eventhub_namespace_authorization_rule" "auth_rule" {
  for_each            = { for idx, policy in local.acess_policies : "${policy.ns_key}.${policy.policy_key}" => policy }
  name                = each.value.name
  namespace_name      = module.name[each.value.ns_key].name
  resource_group_name = var.rg
  listen              = each.value.is_listen
  send                = each.value.is_send
  manage              = each.value.is_manage
}

resource "azurerm_eventhub" "eventhub" {
  for_each            = { for idx, instance in local.instances : "${instance.ns_key}.${instance.instance_key}" => instance }
  name                = each.value.name
  namespace_name      = module.name[each.value.ns_key].name
  resource_group_name = var.rg
  partition_count     = each.value.partition_count
  message_retention   = each.value.msg_retention
}

resource "azurerm_eventhub_authorization_rule" "instance_auth_rule" {
  for_each            = { for idx, instance in local.instances : "${instance.ns_key}.${instance.instance_key}" => instance if instance.auth_rule != null }
  name                = each.value.auth_rule.name
  namespace_name      = module.name[each.value.ns_key].name
  eventhub_name       = azurerm_eventhub.eventhub[each.key].name
  resource_group_name = var.rg
  listen              = each.value.auth_rule.is_listen
  send                = each.value.auth_rule.is_send
  manage              = each.value.auth_rule.is_manage
}

module "rbac" {
  source   = "../rbac"
  for_each = { for idx, rbac in local.rbac : "${rbac.svc_key}.${rbac.rbac_key}" => rbac }
  rbac = [{
    scope   = azurerm_eventhub_namespace.eventhub_ns[each.value.svc_key].id
    role    = each.value.role
    members = each.value.members
  }]
}

module "pe" {
  source       = "../private_endpoint"
  for_each     = { for idx, ns in var.eventhub_ns : idx => ns }
  rg           = var.rg
  location     = var.location
  snet_id      = var.pe_snet_id
  res_name     = module.name[each.key].name
  res_type     = "eventhub_namespace"
  res_id       = azurerm_eventhub_namespace.eventhub_ns[each.key].id
  subresources = ["namespace"]
}
