module "name" {
  for_each = { for idx, func in var.linux_func : idx => func }
  source   = "../../general/name_conv"
  env      = var.env
  prj_id   = var.prj_id
  workload = each.value.workload
  type     = "func"
}

module "sa" {
  source     = "../storage_account"
  env        = var.env
  prj_id     = var.prj_id
  location   = var.location
  rg         = var.rg
  pe_snet_id = var.pe_snet_id
  sa = [merge({
    tags = {
      "target-resource-type" = "linux_function_app"
      "target-resource-name" = length(module.name) > 1 ? join(",", values(module.name)[*].name) : module.name[0].name
    }
  }, var.sa)]
}

resource "azurerm_linux_function_app" "linux_func" {
  for_each                      = { for idx, func in var.linux_func : idx => func }
  name                          = module.name[each.key].name
  resource_group_name           = var.rg
  location                      = var.location
  service_plan_id               = var.asp_id
  app_settings                  = each.value.app_settings
  https_only                    = each.value.is_https_only
  virtual_network_subnet_id     = var.vnet_integration_snet_id
  storage_account_name          = module.sa.name[0]
  storage_account_access_key    = module.sa.primary_access_key[0]
  public_network_access_enabled = false

  tags = {
    "target-resource-type" = "linux_function_app"
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
      python_version          = each.value.stack.python_version
      powershell_core_version = each.value.stack.powershell_core_version
      dynamic "docker" {
        for_each = each.value.stack.docker != null ? [1] : []
        content {
          registry_url      = each.value.stack.docker.registry_url
          image_name        = each.value.stack.docker.image_name
          image_tag         = each.value.stack.docker.image_tag
          registry_username = each.value.stack.docker.registry_username
        }
      }
    }

    dynamic "ip_restriction" {
      for_each = { for idx, rule in local.rules : "${rule.app_key}.${rule.rule_key}" => rule }
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
  for_each = { for idx, rbac in local.rbac : "${rbac.func_key}.${rbac.role_key}" => rbac }
  rbac = [{
    scope         = azurerm_linux_function_app.linux_func[each.value.app_key].id
    role          = each.value.role
    principal_ids = each.value.principal_ids
  }]
}

module "pe" {
  source       = "../private_endpoint"
  for_each     = { for idx, app in var.linux_func : idx => app }
  rg           = var.rg
  location     = var.location
  snet_id      = var.pe_snet_id
  res_name     = module.name[each.key].name
  res_type     = "linux_function_app"
  res_id       = azurerm_linux_function_app.linux_func[each.key].id
  subresources = ["sites"]
}