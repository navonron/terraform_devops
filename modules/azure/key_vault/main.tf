module "name" {
  source   = "../../general/name_conv"
  for_each = { for idx, kv in var.kv : idx => kv }
  env      = var.env
  prj_id   = var.prj_id
  workload = each.value.workload
  type     = "kv"
}

resource "azurerm_key_vault" "kv" {
  for_each                      = { for idx, kv in var.kv : idx => kv }
  name                          = module.name[each.key].name
  resource_group_name           = var.rg
  location                      = var.location
  tags                          = each.value.tags
  tenant_id                     = var.tenant_id
  enable_rbac_authorization     = each.value.is_rbac_auth
  enabled_for_disk_encryption   = each.value.is_disk_encryption
  soft_delete_retention_days    = each.value.soft_delete_days
  sku_name                      = "standard"
  public_network_access_enabled = false
  purge_protection_enabled      = true

  dynamic "network_acls" {
    for_each = each.value.networking != null ? [1] : []
    content {
      default_action             = "Deny"
      bypass                     = each.value.networking.bypass
      ip_rules                   = each.value.networking.allow_ips
      virtual_network_subnet_ids = each.value.networking.allow_snets
    }
  }
}

module "rbac" {
  source   = "../rbac"
  for_each = { for idx, rbac in local.rbac : "${rbac.svc_key}.${rbac.rbac_key}" => rbac }
  rbac = [{
    scope   = azurerm_key_vault.kv[each.value.svc_key].id
    role    = each.value.role
    members = each.value.members
  }]
}

module "pe" {
  source       = "../private_endpoint"
  for_each     = { for idx, kv in var.kv : idx => kv }
  rg           = var.rg
  location     = var.location
  snet_id      = var.pe_snet_id
  res_name     = module.name[each.key].name
  res_type     = "key_vault"
  res_id       = azurerm_key_vault.kv[each.key].id
  subresources = ["vault"]
}
