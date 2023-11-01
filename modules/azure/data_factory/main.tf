module "name" {
  source   = "../../general/name_conv"
  for_each = { for idx, adf in var.adf : idx => adf }
  env      = var.env
  prj_id   = var.prj_id
  workload = each.value.workload
  type     = "adf"
}

resource "azurerm_data_factory" "adf" {
  for_each                        = { for idx, adf in var.adf : idx => adf }
  name                            = module.name[each.key].name
  resource_group_name             = var.rg
  location                        = var.location
  tags                            = each.value.tags
  managed_virtual_network_enabled = each.value.is_managed_vnet
  public_network_enabled          = false

  identity {
    type = "SystemAssigned"
  }

  dynamic "global_parameter" {
    for_each = { for idx, parm in local.global_params : "${parm.adf_key}.${parm.parm_key}" => parm }
    content {
      name  = global_parameter.value.name
      type  = global_parameter.value.type
      value = global_parameter.value.value
    }
  }
}

module "rbac" {
  source   = "../rbac"
  for_each = { for idx, rbac in local.rbac : "${rbac.svc_key}.${rbac.rbac_key}" => rbac }
  rbac = [{
    scope   = azurerm_data_factory.adf[each.value.svc_key].id
    role    = each.value.role
    members = each.value.members
  }]
}

module "pe" {
  source       = "../private_endpoint"
  for_each     = { for idx, adf in var.adf : idx => adf }
  rg           = var.rg
  location     = var.location
  snet_id      = var.pe_snet_id
  res_name     = module.name[each.key].name
  res_type     = "data_factory"
  res_id       = azurerm_data_factory.adf[each.key].id
  subresources = ["dataFactory"]
}

resource "azurerm_data_factory_linked_service_key_vault" "link_kv" {
  for_each        = { for idx, adf in var.adf : idx => adf }
  name            = "link_${module.name[each.key].name}"
  key_vault_id    = var.link_kv_id
  data_factory_id = azurerm_data_factory.adf[each.key].id
}
