module "name" {
  source   = "../../general/name_conv"
  for_each = { for idx, adb in var.databricks : idx => adb }
  env      = var.env
  prj_id   = var.prj_id
  workload = each.value.workload
  type     = "databricks"
}

module "snet" {
  source   = "../subnet"
  for_each = { for idx, adb in var.databricks : idx => adb if adb.vnet_config != null }
  env      = var.env
  prj_id   = var.prj_id
  snet     = [each.value.vnet_config.public_snet, each.value.vnet_config.private_snet]
}

module "nsg" {
  source   = "../nsg"
  for_each = { for idx, adb in var.databricks : idx => adb if adb.vnet_config != null }
  env      = var.env
  prj_id   = var.prj_id
  rg       = var.rg
  location = var.location
  nsg = [
    {
      workload = "public-snet-adb"
      snet_ids = [module.snet[0].id[0]]
    },
    {
      workload = "private-snet-adb"
      snet_ids = [module.snet[0].id[1]]
    }
  ]
}

resource "azurerm_databricks_workspace" "databricks" {
  for_each                              = { for idx, adb in var.databricks : idx => adb }
  name                                  = module.name[each.key].name
  resource_group_name                   = var.rg
  location                              = var.location
  sku                                   = each.value.sku
  tags                                  = each.value.tags
  managed_resource_group_name           = "mrg-${module.name[each.key].name}"
  public_network_access_enabled         = true
  network_security_group_rules_required = each.value.is_nsg_required
  
  custom_parameters {
    no_public_ip                                         = each.value.add_pip
    virtual_network_id                                   = each.value.vnet_config.vnet_id
    public_subnet_name                                   = each.value.vnet_config.vnet_id != null ? module.snet[0].name[0] : null
    private_subnet_name                                  = each.value.vnet_config.vnet_id != null ? module.snet[0].name[1] : null
    public_subnet_network_security_group_association_id  = each.value.vnet_config.vnet_id != null ? module.nsg[0].id[0] : null
    private_subnet_network_security_group_association_id = each.value.vnet_config.vnet_id != null ? module.nsg[0].id[1] : null
  }
}

module "rbac" {
  source   = "../rbac"
  for_each = { for idx, rbac in local.rbac : "${rbac.svc_key}.${rbac.rbac_key}" => rbac }
  rbac = [{
    scope   = azurerm_databricks_workspace.databricks[each.value.svc_key].id
    role    = each.value.role
    members = each.value.members
  }]
}

module "pe" {
  source       = "../private_endpoint"
  for_each     = { for idx, adb in var.databricks : idx => adb }
  rg           = var.rg
  location     = var.location
  snet_id      = var.pe_snet_id
  res_name     = module.name[each.key].name
  res_type     = "databricks"
  res_id       = azurerm_databricks_workspace.databricks[each.key].id
  subresources = ["databricks_ui_api"]
}

resource "azurerm_databricks_access_connector" "access_connector" {
  for_each            = { for idx, adb in var.databricks : idx => adb }
  name                = "ac-${module.name[each.key].name}"
  resource_group_name = var.rg
  location            = var.location

  identity {
    type = "SystemAssigned"
  }
}













# provider "databricks" {
#   for_each                    = { for idx, adb in var.databricks : idx => adb }
#   host                        = azurerm_databricks_workspace.databricks[each.key].workspace_url
#   azure_workspace_resource_id = azurerm_databricks_workspace.databricks[each.key].id
# }

# resource "databricks_notebook" "ddl" {
#   source = "${path.module}/DDLgen.py"
#   path   = "${data.databricks_current_user.me.home}/AA/BB/CC"
# }

# resource "databricks_repo" "Libraries" {
#   url = "https://github.com/user/demo.git"
# }






























# resource "databricks_workspace_conf" "databricks" {
#   count         = var.sku == "premium" ? 1 : 0
#   custom_config = local.custom_config
#   # {
#   #   "enableIpAccessLists" : var.enable_ip_access_lists,
#   #   "enableTokensConfig" : true,
#   #   # "maxTokenLifetimeDays" : "2"  # cannot delete workspace conf: Some values are not allowed: {"maxTokenLifetimeDays":"false"}
#   #   # "enableAclsConfig" : var.enable_table_access_control
#   # }
# }

# data "external" "myipaddr" {
#   program = ["bash", "-c", "curl -s --connect-timeout 10 -v --noproxy '*' 'https://ipinfo.io/json' || curl -s -v 'https://ipinfo.io/json'"]
# }

# data "external" "proxy_ipaddr" {
#   program = ["bash", "-c", "curl -s 'https://ipinfo.io/json'"]
# }

# resource "databricks_ip_access_list" "allow_iac_ips" {
#   count = var.enable_ip_access_lists ? 1 : 0

#   label        = "allow-iac-ips"
#   list_type    = "ALLOW"
#   ip_addresses = distinct(["${data.external.myipaddr.result.ip}/32", "${data.external.proxy_ipaddr.result.ip}/32"])
#   depends_on   = [databricks_workspace_conf.databricks[0]]
# }
# resource "databricks_ip_access_list" "allow_additional_ips" {
#   count = (var.enable_ip_access_lists && length(var.ip_access_lists) != 0) ? 1 : 0

#   label        = "allow-additional-ips"
#   list_type    = "ALLOW"
#   ip_addresses = var.ip_access_lists
#   depends_on = [
#     databricks_workspace_conf.databricks[0],
#     databricks_ip_access_list.allow_iac_ips[0]
#   ]
# }

# resource "databricks_ip_access_list" "allow_intel_proxy" {
#   count = var.enable_ip_access_lists ? 1 : 0

#   label     = "allow-intel-proxy"
#   list_type = "ALLOW"
#   ip_addresses = [
#     "134.134.139.64/27",
#     "134.134.137.64/27",
#     "192.55.54.32/27",
#     "192.55.55.32/27",
#     "192.198.151.32/27",
#     "134.191.227.32/27",
#     "134.191.220.64/27",
#     "134.191.221.64/27",
#     "134.191.232.64/27",
#     "134.191.233.192/27",
#     "198.175.68.32/27",
#     "192.102.204.32/27",
#     "192.55.46.32/27",
#     "192.55.79.160",
#     "192.55.79.161",
#     "192.55.79.162",
#     "192.55.79.163",
#     "192.55.79.164",
#     "192.55.79.165",
#     "192.55.79.166",
#     "192.55.79.167",
#     "192.55.79.168",
#     "192.55.79.169",
#     "192.55.79.170",
#     "192.55.79.171",
#     "192.55.79.172",
#     "192.55.79.173",
#     "192.55.79.174",
#     "192.55.79.175",
#     "192.55.79.176",
#     "192.55.79.177",
#     "192.55.79.178",
#     "192.55.79.179",
#     "192.55.79.180",
#     "192.55.79.181",
#     "192.55.79.182",
#     "192.55.79.183",
#     "192.55.79.184",
#     "192.55.79.185",
#     "192.55.79.186",
#     "192.55.79.187",
#     "192.55.79.188",
#     "192.55.79.189",
#     "192.55.79.190",
#     "192.198.146.160",
#     "192.198.146.161",
#     "192.198.146.162",
#     "192.198.146.163",
#     "192.198.146.164",
#     "192.198.146.165",
#     "192.198.146.166",
#     "192.198.146.167",
#     "192.198.146.168",
#     "192.198.146.169",
#     "192.198.146.170",
#     "192.198.146.171",
#     "192.198.146.172",
#     "192.198.146.173",
#     "192.198.146.174",
#     "192.198.146.175",
#     "192.198.146.176",
#     "192.198.146.177",
#     "192.198.146.178",
#     "192.198.146.179",
#     "192.198.146.180",
#     "192.198.146.181",
#     "192.198.146.182",
#     "192.198.146.183",
#     "192.198.146.184",
#     "192.198.146.185",
#     "192.198.146.186",
#     "192.198.146.187",
#     "192.198.146.188",
#     "192.198.146.189",
#     "192.198.146.190",
#     "192.198.147.160",
#     "192.198.147.161",
#     "192.198.147.162",
#     "192.198.147.163",
#     "192.198.147.164",
#     "192.198.147.165",
#     "192.198.147.166",
#     "192.198.147.167",
#     "192.198.147.168",
#     "192.198.147.169",
#     "192.198.147.170",
#     "192.198.147.171",
#     "192.198.147.172",
#     "192.198.147.173",
#     "192.198.147.174",
#     "192.198.147.175",
#     "192.198.147.176",
#     "192.198.147.177",
#     "192.198.147.178",
#     "192.198.147.179",
#     "192.198.147.180",
#     "192.198.147.181",
#     "192.198.147.182",
#     "192.198.147.183",
#     "192.198.147.184",
#     "192.198.147.185",
#     "192.198.147.186",
#     "192.198.147.187",
#     "192.198.147.188",
#     "192.198.147.189",
#     "192.198.147.190"
#   ]
#   depends_on = [
#     databricks_workspace_conf.databricks[0],
#     databricks_ip_access_list.allow_iac_ips[0]
#   ]
# }



# # TODO: Add policy to restrict VM SKUs
# # TODO: Add policy to enforce remote logging with storage accounts.
# # TODO: Add global init script for storage account and HMS connectivity.
