module "name" {
  source   = "../../general/name_conv"
  for_each = { for idx, synapse in var.synapse : idx => synapse }
  env      = var.env
  prj_id   = var.prj_id
  workload = each.value.workload
  type     = "synapse"
}

module "sa" {
  source     = "../storage_account"
  for_each   = { for idx, synapse in var.synapse : idx => synapse }
  env        = var.env
  prj_id     = var.prj_id
  location   = var.location
  rg         = var.rg
  pe_snet_id = var.pe_snet_id
  sa = [merge({
    tags = {
      "target-resource-type" = "synapse"
      "target-resource-name" = module.name[each.key].name
    }
  }, each.value.sa)]
}

module "sa_file_sys" {
  source   = "../sa_file_sys"
  for_each = { for idx, synapse in var.synapse : idx => synapse }
  sa_name  = module.sa[0].name[each.key]
  sa_id    = module.sa[0].id[each.key]
  ace      = each.value.sa_file_sys_ace
}

resource "random_password" "pwd" {
  for_each = { for idx, synapse in var.synapse : idx => synapse }
  length   = 16
  keepers = {
    result = length(var.synapse)
  }
}

module "kv_secret" {
  source   = "../kv_secret"
  for_each = { for idx, synapse in var.synapse : idx => synapse }
  env      = var.env
  prj_id   = var.prj_id
  kv_secret = [{
    kv_id        = var.kv_id
    workload     = each.value.workload
    usage        = "${module.name[each.key].name}-pwd"
    value        = random_password.pwd[each.key].result
    content_type = "password"
  }]
}

resource "azurerm_synapse_workspace" "synapse" {
  for_each                             = { for idx, synapse in var.synapse : idx => synapse }
  name                                 = module.name[each.key].name
  resource_group_name                  = var.rg
  location                             = var.location
  tags                                 = each.value.tags
  storage_data_lake_gen2_filesystem_id = module.sa_file_sys[each.key].id
  sql_administrator_login              = each.value.admin_user
  sql_administrator_login_password     = random_password.pwd[each.key].result
  managed_resource_group_name          = "mrg-${module.name[each.key].name}"
  public_network_access_enabled        = false
  data_exfiltration_protection_enabled = true
  managed_virtual_network_enabled      = true

  identity {
    type = "SystemAssigned"
  }
}

module "synapse_sa_rbac" {
  for_each = { for idx, synapse in var.synapse : idx => synapse }
  source   = "../rbac"
  rbac = [{
    scope   = module.sa[0].id[each.key]
    role    = "Storage Blob Data Contributor"
    members = [azurerm_synapse_workspace.synapse[each.key].identity.0.principal_id]
  }]
}

module "rbac" {
  source   = "../rbac"
  for_each = { for idx, rbac in local.rbac : "${rbac.svc_key}.${rbac.rbac_key}" => rbac }
  rbac = [{
    scope   = azurerm_synapse_workspace.synapse[each.value.svc_key].id
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
  res_type     = "synapse${each.value.workload == null ? "_${each.value.workload}" : ""}"
  res_id       = azurerm_synapse_workspace.synapse[each.value.svc_key].id
  subresources = [each.value.subresource]
}

resource "azurerm_synapse_workspace_sql_aad_admin" "synapse_aad_admin" {
  for_each             = { for idx, synapse in var.synapse : idx => synapse if synapse.aad_admin_object_id != null }
  synapse_workspace_id = azurerm_synapse_workspace.synapse[each.key].id
  login                = "AzureAD SQL Admin"
  object_id            = each.value.aad_admin_object_id
  tenant_id            = var.tenant_id
}

module "synapse_sql_pool" {
  source           = "../synapse_sql_pool"
  for_each         = { for idx, synapse in var.synapse : idx => synapse if synapse.synapse_sql_pool != null }
  env              = var.env
  prj_id           = var.prj_id
  synapse_id       = azurerm_synapse_workspace.synapse[each.key].id
  synapse_sql_pool = [each.value.synapse_sql_pool]
}

resource "azurerm_synapse_role_assignment" "synapse_role" {
  for_each             = { for idx, role in local.synapse_role : "${role.synapse_key}.${role.role_key}.${role.member_key}" => role }
  synapse_workspace_id = azurerm_synapse_workspace.synapse[each.value.synapse_key].id
  role_name            = each.value.role
  principal_id         = each.value.member
}

resource "azurerm_synapse_managed_private_endpoint" "mpe" {
  for_each             = { for idx, mpe in local.mpe : "${mpe.synapse_key}.${mpe.mpe_key}" => mpe }
  name                 = "mpe-${each.value.target_name}"
  synapse_workspace_id = azurerm_synapse_workspace.synapse[each.value.synapse_key].id
  target_resource_id   = each.value.target_id
  subresource_name     = each.value.target_subresource
}
