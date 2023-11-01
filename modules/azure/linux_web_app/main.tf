# module "name" {
#   for_each = { for idx, app in var.linux_web_app : idx => app }
#   source   = "../../general/name_conv"
#   env      = var.env
#   prj_id   = var.prj_id
#   workload = each.value.workload
#   type     = "app"
# }

# resource "azurerm_linux_web_app" "linux_web_app" {
#   for_each                      = { for idx, app in var.linux_web_app : idx => app }
#   name                          = module.name[each.key].name
#   resource_group_name           = var.rg
#   location                      = var.location
#   service_plan_id               = var.asp_id
#   app_settings                  = each.value.app_settings
#   https_only                    = each.value.is_https_only
#   public_network_access_enabled = each.value.is_public
#   virtual_network_subnet_id     = var.vnet_integration_snet_id

#   tags = {
#     "target-resource-type" = "web_app_linux"
#     "target-resource-name" = module.name[each.key].name
#   }

#   identity {
#     type = "SystemAssigned"
#   }

#   site_config {
#     vnet_route_all_enabled = var.vnet_integration_snet_id != null ? true : false

#     application_stack {
#       docker_image_name        = each.value.docker_config != null ? each.value.docker_config.image : null
#       docker_registry_url      = each.value.docker_config != null ? each.value.docker_config.registry_url : null
#       docker_registry_username = each.value.docker_config != null ? each.value.docker_config.username : null
#       docker_registry_password = each.value.docker_config != null ? each.value.docker_config.password : null
#       dotnet_version           = each.value.stack == "dotnet" ? each.value.version : null
#       go_version               = each.value.stack == "go" ? each.value.version : null
#       java_version             = each.value.stack == "java" ? each.value.version : null
#       node_version             = each.value.stack == "node" ? each.value.version : null
#       php_version              = each.value.stack == "php" ? each.value.version : null
#       python_version           = each.value.stack == "python" ? each.value.version : null
#       ruby_version             = each.value.stack == "ruby" ? each.value.version : null
#     }

#     dynamic "ip_restriction" {
#       for_each = { for idx, rule in local.rules : "${rule.app_key}.${rule.rule_key}" => rule }
#       content {
#         action                    = each.value.action
#         priority                  = each.value.priority
#         ip_address                = each.value.allow_ip
#         virtual_network_subnet_id = each.value.allow_snet
#         service_tag               = each.value.service_tag
#       }
#     }
#   }
# }

# module "rbac" {
#   source   = "../rbac"
#   for_each = { for idx, rbac in local.rbac : "${rbac.app_key}.${rbac.role_key}" => rbac }
#   rbac = [{
#     scope         = azurerm_linux_web_app.linux_web_app[each.value.app_key].id
#     role          = each.value.role
#     principal_ids = each.value.principal_ids
#   }]
# }

# module "pe" {
#   source       = "../private_endpoint"
#   for_each     = { for idx, app in var.linux_web_app : idx => app }
#   rg           = var.rg
#   location     = var.location
#   snet_id      = var.pe_snet_id
#   res_name     = module.name[each.key].name
#   res_type     = "linux_web_app"
#   res_id       = azurerm_windows_web_app.windows_web_app[each.key].id
#   subresources = ["sites"]
# }
