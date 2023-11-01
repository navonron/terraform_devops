module "name" {
  source   = "../../general/name_conv"
  for_each = { for idx, app in var.windows_web_app : idx => app }
  env      = var.env
  prj_id   = var.prj_id
  workload = each.value.workload
  type     = "app"
}

resource "azurerm_windows_web_app" "web_app" {
  for_each                      = { for idx, app in var.windows_web_app : idx => app }
  name                          = module.name[each.key].name
  resource_group_name           = var.rg
  location                      = var.location
  service_plan_id               = var.asp_id
  app_settings                  = each.value.app_settings
  virtual_network_subnet_id     = var.vnet_integration_snet_id
  public_network_access_enabled = false
  https_only                    = true

  tags = {
    "target-resource-type" = "web_app_windows"
    "target-resource-name" = module.name[each.key].name
  }

  identity {
    type = "SystemAssigned"
  }

  site_config {
    vnet_route_all_enabled = var.vnet_integration_snet_id != null ? true : false
    application_stack {
      current_stack            = each.value.stack != "docker" ? each.value.stack : null
      docker_image_name        = each.value.docker_config != null ? each.value.docker_config.image : null
      docker_registry_url      = each.value.docker_config != null ? each.value.docker_config.registry_url : null
      docker_registry_username = each.value.docker_config != null ? each.value.docker_config.username : null
      docker_registry_password = each.value.docker_config != null ? each.value.docker_config.password : null
      dotnet_version           = each.value.stack == "dotnet" ? each.value.version : null
      dotnet_core_version      = each.value.stack == "dotnetcore" ? each.value.version : null
      node_version             = each.value.stack == "node" ? each.value.version : null
      python                   = each.value.stack == "python" ? each.value.version : null
      php_version              = each.value.stack == "php" ? each.value.version : null
      java_version             = each.value.stack == "java" ? each.value.version : null
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
  for_each = { for idx, rbac in local.rbac : "${rbac.svc_key}.${rbac.rbac_key}" => rbac }
  rbac = [{
    scope   = azurerm_windows_web_app.web_app[each.value.svc_key].id
    role    = each.value.role
    members = each.value.members
  }]
}

module "pe" {
  source       = "../private_endpoint"
  for_each     = { for idx, app in var.windows_web_app : idx => app }
  rg           = var.rg
  location     = var.location
  snet_id      = var.pe_snet_id
  res_name     = module.name[each.key].name
  res_type     = "windows_web_app"
  res_id       = azurerm_windows_web_app.web_app[each.key].id
  subresources = ["sites"]
}
