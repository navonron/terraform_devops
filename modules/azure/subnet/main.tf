module "name" {
  for_each  = { for idx, snet in var.snet : idx => snet }
  source    = "../../general/name_conv"
  env       = var.env
  prj_id    = var.prj_id
  is_public = each.value.is_public
  workload  = each.value.workload
  type      = "snet"
}

resource "azurerm_subnet" "snet" {
  for_each             = { for idx, snet in var.snet : idx => snet }
  name                 = module.name[each.key].name
  resource_group_name  = each.value.vnet_rg
  virtual_network_name = each.value.vnet_name
  address_prefixes     = [each.value.ip_range]

  dynamic "delegation" {
    for_each = each.value.delegation != null ? [1] : []
    content {
      name = "delegation-${module.name[each.key].name}"

      service_delegation {
        actions = each.value.delegation.actions
        name    = each.value.delegation.service_delegation
      }
    }
  }
}
