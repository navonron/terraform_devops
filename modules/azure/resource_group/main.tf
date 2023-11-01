module "name" {
  source   = "../../general/name_conv"
  for_each = { for idx, rg in var.rg : idx => rg }
  env      = var.env
  prj_id   = var.prj_id
  workload = each.value.workload
  type     = "rg"
}

resource "azurerm_resource_group" "rg" {
  for_each = { for idx, rg in var.rg : idx => rg }
  name     = module.name[each.key].name
  location = var.location
  tags     = var.tags
}

module "rbac" {
  source   = "../rbac"
  for_each = { for idx, rbac in local.rbac : "${rbac.svc_key}.${rbac.rbac_key}" => rbac }
  rbac = [{
    scope   = azurerm_resource_group.rg[each.value.svc_key].id
    role    = each.value.role
    members = each.value.members
  }]
}
