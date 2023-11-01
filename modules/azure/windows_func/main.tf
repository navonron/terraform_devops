module "name" {
  source   = "../../general/name_conv"
  for_each = { for idx, func in var.windows_func : idx => func }
  env      = var.env
  prj_id   = var.prj_id
  workload = each.value.workload
  type     = "func"
}

resource "azurerm_windows_function_app" "func" {
  for_each                      = { for idx, func in var.windows_func : idx => func }
  name                          = module.name[each.key].name
  resource_group_name           = var.rg
  location                      = var.location
  service_plan_id               = var.asp_id
  app_settings                  = each.value.app_settings
  https_only                    = each.value.is_https_only
  virtual_network_subnet_id     = var.vnet_integration_snet_id
  storage_account_name          = var.sa_name
  storage_account_access_key    = var.sa_primary_access_key
  public_network_access_enabled = false

  tags = {
    "target-resource-type" = "windows_function_app"
    "target-resource-name" = module.name[each.key].name
  }

  identity {
    type = "SystemAssigned"
  }

  site_config {
    vnet_route_all_enabled = var.vnet_integration_snet_id != null ? true : false

    application_stack {
      dotnet_version          = each.value.stack.dotnet_version
      java_version            = each.value.stack.java_version
      node_version            = each.value.stack.node_version
      powershell_core_version = each.value.stack.powershell_core_version
      use_custom_runtime      = each.value.stack.is_custom_runtime
    }

    dynamic "ip_restriction" {
      for_each = { for idx, rule in local.rules : "${rule.func_key}.${rule.rule_key}" => rule }
      content {
        action                    = each.value.action
        priority                  = each.value.priority
        ip_address                = each.value.allow_ip
        virtual_network_subnet_id = each.value.allow_snet
        service_tag               = each.value.service_tag
      }
    }
  }
}

module "rbac" {
  source   = "../rbac"
  for_each = { for idx, rbac in local.rbac : "${rbac.svc_key}.${rbac.rbac_key}" => rbac }
  rbac = [{
    scope   = azurerm_windows_function_app.func[each.value.svc_key].id
    role    = each.value.role
    members = each.value.members
  }]
}

module "pe" {
  source       = "../private_endpoint"
  for_each     = { for idx, app in var.windows_func : idx => app }
  rg           = var.rg
  location     = var.location
  snet_id      = var.pe_snet_id
  res_name     = module.name[each.key].name
  res_type     = "windows_function_app"
  res_id       = azurerm_windows_function_app.func[each.key].id
  subresources = ["sites"]
}

resource "azurerm_windows_function_app_slot" "slot" {
  for_each                      = { for idx, slot in local.slots : "${slot.func_key}.${slot.slot_key}" => slot }
  name                          = "${module.name[each.value.func_key].name}-slot${each.value.slots[each.value.slot_key].workload != null ? "-${each.value.slots[each.value.slot_key].workload}" : ""}"
  function_app_id               = azurerm_windows_function_app.func[each.value.func_key].id
  storage_account_name          = var.sa_name
  virtual_network_subnet_id     = each.value.slots[each.value.slot_key].add_vnet_integration == true ? var.vnet_integration_snet_id : null
  public_network_access_enabled = false

  site_config {
    vnet_route_all_enabled = each.value.slots[each.value.slot_key].add_vnet_integration == true ? true : false
  }
}
