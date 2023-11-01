module "name" {
  for_each = { for idx, asp in var.asp : idx => asp }
  source   = "../../general/name_conv"
  env      = var.env
  prj_id   = var.prj_id
  workload = each.value.workload
  asp_os   = each.value.os
  type     = "asp"
}

resource "azurerm_service_plan" "asp" {
  for_each                     = { for idx, asp in var.asp : idx => asp }
  name                         = module.name[each.key].name
  tags                         = each.value.tags
  resource_group_name          = var.rg
  location                     = var.location
  os_type                      = each.value.os
  sku_name                     = each.value.sku
  zone_balancing_enabled       = each.value.is_zrs
  maximum_elastic_worker_count = strcontains(each.value.sku, "E") ? each.value.max_elastic : null
  worker_count                 = each.value.instances
}
