terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.2"
    }
  }
  backend "azurerm" {} # Backend parameters will be provided during the runtime.
}

provider "azurerm" {
  subscription_id     = var.subscription_id
  storage_use_azuread = true
  features {}
}
provider "azurerm" {
  alias               = "platform"
  subscription_id     = local.platform_config.tf_backend_subscription_id
  storage_use_azuread = true
  features {}
}
provider "azurerm" {
  alias                      = "dns"
  subscription_id            = local.platform_config.private_dns_zone_subscription_id
  skip_provider_registration = true
  features {}
}

locals {
  platform_config = jsondecode(file("${path.module}/../../../platform_tfconfig.${var.environment}.json"))

  app_service_name_suffix   = ["adfhandler", "collectionhelper", "dbhandler", "metadata", "sdkdoc", "storage"]
  function_app_name_suffix  = ["arm", "collectionflow", "policyorch", "persistence"]
  func_storage_account_name = "stfunc${var.project_id}${var.environment}${random_string.random_suffix.result}"
}

data "azurerm_client_config" "current" {}
data "azurerm_key_vault_secret" "platfrom_sp" {
  key_vault_id = local.platform_config.key_vault_id
  name         = "iac-spn"
}

resource "random_string" "random_suffix" {
  length  = 4
  lower   = true
  upper   = false
  numeric = false
  special = false
}










#########################################################################################   START   #########################################################################################
# Create resource grop
# module "resource_group" {
#   source = "../../../modules/azure/resource_group"

#   environment   = var.environment
#   project_id    = var.project_id
#   random_suffix = random_string.random_suffix.result
#   location      = var.location
#   project_iap   = var.project_iap

#   entitlement_lookup = var.entitlement_lookup
#   access_mapping     = var.resource_group_access_mapping

#   tags = var.tags
# }

# #Key Vault
# module "key_vault" {
#   source = "../../../modules/azure/key_vault"
#   providers = {
#     azurerm.dns_forwarding = azurerm.dns
#   }

#   environment   = var.environment
#   project_id    = var.project_id
#   random_suffix = random_string.random_suffix.result
#   location      = var.location

#   resource_group_name         = module.resource_group.name
#   purge_protection_enabled    = true # needed for cmk disk encryption
#   enabled_for_disk_encryption = true # needed for cmk disk encryption

#   private_link_resource_group = var.private_link_resource_group
#   private_link_vnet_name      = var.private_link_vnet_name
#   private_link_subnet_name    = var.private_link_subnet_name
#   add_local_host_entry        = true
#   add_private_dns_forwarding  = var.add_private_dns_forwarding
#   enable_private_link = true
#   entitlement_lookup = var.entitlement_lookup
#   access_mapping     = var.key_vault_access_mapping

#   tags = var.tags
# }

# Data Factory
# module "data_factory" {
#   source = "../../../modules/azure/data_factory"
#   providers = {
#     azurerm.dns_forwarding = azurerm.dns
#   }

#   environment   = var.environment
#   project_id    = var.project_id
#   random_suffix = random_string.random_suffix.result

#   resource_group_name = module.resource_group.name

#   private_link_resource_group = var.private_link_resource_group
#   private_link_vnet_name      = var.private_link_vnet_name
#   private_link_subnet_name    = var.private_link_subnet_name
#   add_private_dns_forwarding  = var.add_private_dns_forwarding

#   enable_diagnostic_setting  = var.datafactory_enable_diagnostic_setting
#   log_analytics_workspace_id = module.log_analytics_workspace.id
#   log_retention_days         = var.datafactory_log_retention_days

#   tags = var.tags
# }

resource "azurerm_role_assignment" "adf_to_kv" {
  scope                = module.key_vault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.data_factory.managed_identity_object_id
}

# #Databricks
# module "databricks" {
#   source = "../../../modules/azure/databricks_workspace"
#   providers = {
#     azurerm.dns_forwarding = azurerm.dns
#   }

#   environment   = var.environment
#   project_id    = var.project_id
#   random_suffix = random_string.random_suffix.result
#   location      = var.location

#   resource_group_name = module.resource_group.name

#   virtual_network_name                = var.databricks_vnet_name
#   virtual_network_resource_group_name = var.databricks_vnet_resource_group != "" ? var.databricks_vnet_resource_group : var.private_link_resource_group
#   public_subnet_address_prefix        = var.databricks_public_subnet_address_prefix
#   private_subnet_address_prefix       = var.databricks_private_subnet_address_prefix

#   private_link_resource_group   = var.private_link_resource_group
#   private_link_vnet_name        = var.private_link_vnet_name
#   private_link_subnet_name      = var.private_link_subnet_name
#   public_network_access_enabled = var.databricks_public_network_access_enabled
#   enable_private_link           = var.databricks_enable_private_link

#   tags = var.tags
# }

# Synapse Workspace
module "synapse_workspace" {
  source = "../../../modules/azure/synapse_workspace"
  providers = {
    azurerm.dns_forwarding = azurerm.dns
    azurerm.keyvault       = azurerm
  }

  environment   = var.environment
  project_id    = var.project_id
  random_suffix = random_string.random_suffix.result
  location      = var.location

  resource_group_name = module.resource_group.name
  key_vault_id        = module.key_vault.id

  entitlement_lookup = var.entitlement_lookup
  access_mapping     = var.synapse_workspace_access_mapping

  private_link_resource_group = var.private_link_resource_group
  private_link_vnet_name      = var.private_link_vnet_name
  private_link_subnet_name    = var.private_link_subnet_name
  add_private_dns_forwarding  = var.add_private_dns_forwarding
  add_local_host_entry        = true

  tags = var.tags

}

# Synapse Sql Pool
# module "synapse_sql_pool" {
#   source = "../../../modules/azure/synapse_sql_pool"

#   environment   = var.environment
#   project_id    = var.project_id
#   random_suffix = random_string.random_suffix.result

#   synapse_workspace_id = module.synapse_workspace.id
#   sku_name             = var.synapse_sku_name

#   tags = var.tags
#   depends_on = [
#     module.synapse_workspace
#   ]
# }

resource "azurerm_role_assignment" "synw_to_storage_account" {
  scope                = module.storage_account.id
  role_definition_name = "storage Blob Data Contributor"
  principal_id         = module.synapse_workspace.managed_identity_object_id
}
#########################################################################################     END     #########################################################################################






















#Log Analytics Workspace
module "log_analytics_workspace" {
  source = "../../../modules/azure/log_analytics_workspace"

  environment   = var.environment
  project_id    = var.project_id
  location      = var.location
  random_suffix = random_string.random_suffix.result


  resource_group_name = module.resource_group.name

  entitlement_lookup = var.entitlement_lookup
  access_mapping     = {}

  tags = var.tags
}

# Disk encrypting set for ADF SHIR vm
module "disk_encryption_set" {
  source = "../../../modules/azure/disk_encryption_set"

  environment   = var.environment
  project_id    = var.project_id
  random_suffix = random_string.random_suffix.result

  resource_group_name = module.resource_group.name
  azure_key_vault_id  = module.key_vault.id

}

# ADF SHIR VM
module "virtual_machine_windows" {
  source = "../../../modules/azure/virtual_machine_windows"
  providers = {
    azurerm.platform = azurerm.platform
  }
  environment   = var.environment
  project_id    = var.project_id
  random_suffix = random_string.random_suffix.result

  resource_group_name         = module.resource_group.name
  name_suffix                 = "sir"
  size                        = var.shir_windows_vm_size
  sku                         = var.shir_windows_vm_sku
  admin_password_key_vault_id = local.platform_config.key_vault_id
  disk_encryption_set_id      = module.disk_encryption_set.id

  log_analytics_workspace_name                = module.log_analytics_workspace.name
  log_analytics_workspace_resource_group_name = module.resource_group.name

  virtual_network_resource_group_name = var.private_link_resource_group
  virtual_network_name                = var.private_link_vnet_name
  virtual_network_subnet_name         = var.private_link_subnet_name

  entitlement_lookup = var.entitlement_lookup
  access_mapping     = {}
}

resource "azurerm_role_assignment" "adb_to_kv" {
  scope                = module.key_vault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = "fa8d6817-4139-46c9-ae91-232687b8f078"
}



















#########################################################################################   START   #########################################################################################
#App Service Plan
module "service_plan" {
  source = "../../../modules/azure/service_plan"

  environment   = var.environment
  project_id    = var.project_id
  location      = var.location
  random_suffix = random_string.random_suffix.result

  resource_group_name = module.resource_group.name
  name_suffix         = var.service_plan_name_suffix
  os_type             = var.service_plan_os_type
  sku_name            = var.service_plan_sku_name

  tags = var.tags
}

#App Service 
module "web_app" {
  source = "../../../modules/azure/web_app"

  for_each = { for idx, record in local.app_service_name_suffix : "webapp-for-${record}" => record }

  environment   = var.environment
  project_id    = var.project_id
  location      = var.location
  random_suffix = random_string.random_suffix.result

  resource_group_name = module.resource_group.name
  name_suffix         = each.value
  service_plan_name   = module.service_plan.name
  runtime_version     = var.web_app_runtime_version # windows|dotnet|v5.0

  key_vault_id = module.key_vault.id

  private_link_resource_group         = var.private_link_resource_group
  private_link_vnet_name              = var.private_link_vnet_name
  private_link_subnet_name            = var.private_link_subnet_name
  add_local_host_entry                = true
  outbound_vnet_integration_subnet_id = var.web_app_outbound_vnet_integration_subnet_id

  enable_application_insights       = true
  application_insights_workspace_id = module.log_analytics_workspace.id

  tags = var.tags
}

# Storage Account
# module "storage_account" {
#   source = "../../../modules/azure/storage_account"
#   providers = {
#     azurerm.dns_forwarding = azurerm.dns
#   }


#   environment   = var.environment
#   project_id    = var.project_id
#   random_suffix = random_string.random_suffix.result

#   resource_group_name = module.resource_group.name
#   location            = var.location

#   account_replication_type  = var.storage_account_replication_type
#   shared_access_key_enabled = true

#   entitlement_lookup = var.entitlement_lookup
#   access_mapping     = var.storage_account_access_mapping

#   enable_private_link         = var.enable_private_link
#   private_link_resource_group = var.private_link_resource_group
#   private_link_vnet_name      = var.private_link_vnet_name
#   private_link_subnet_name    = var.private_link_subnet_name
#   private_endpoint_resources  = ["blob", "dfs", "queue", "file", "table"]
#   add_private_dns_forwarding  = var.add_private_dns_forwarding

#   add_local_host_entry = var.add_local_host_entry

#   tags = var.tags
# }

# # Storage Account for Function App
# module "function_app_storage_account" {
#   source = "../../../modules/azure/storage_account"
#   providers = {
#     azurerm.dns_forwarding = azurerm.dns
#   }


#   environment   = var.environment
#   project_id    = var.project_id
#   random_suffix = random_string.random_suffix.result

#   resource_group_name = module.resource_group.name
#   name                = local.func_storage_account_name
#   location            = var.location

#   account_replication_type  = var.storage_account_replication_type
#   shared_access_key_enabled = true

#   entitlement_lookup = var.entitlement_lookup
#   access_mapping     = var.storage_account_access_mapping

#   enable_private_link         = var.enable_private_link
#   private_link_resource_group = var.private_link_resource_group
#   private_link_vnet_name      = var.private_link_vnet_name
#   private_link_subnet_name    = var.private_link_subnet_name
#   private_endpoint_resources  = ["blob", "dfs", "queue", "file", "table"]
#   add_private_dns_forwarding  = var.add_private_dns_forwarding

#   add_local_host_entry = var.add_local_host_entry

#   tags = merge(
#     {
#       "target_resource_type" = "function_app"
#       "target_resource_name" = join(",", [for i in local.function_app_name_suffix : "func-${var.project_id}-${i}-${var.environment}-${random_string.random_suffix.result}"])
#     },
#     var.tags
#   )
# }

# Function App
module "function_app" {
  source = "../../../modules/azure/function_app"

  for_each = { for idx, record in local.function_app_name_suffix : "func-pdaibi-${record}" => record }

  environment         = var.environment
  project_id          = var.project_id
  random_suffix       = random_string.random_suffix.result
  name_suffix         = each.value
  resource_group_name = module.resource_group.name


  service_plan_name    = module.service_plan.name
  storage_account_name = module.function_app_storage_account.name
  runtime_version      = var.function_app_runtime_version # windows|DOTNET|6

  key_vault_id = module.key_vault.id

  enable_private_link                 = true
  private_link_resource_group         = var.private_link_resource_group
  private_link_vnet_name              = var.private_link_vnet_name
  private_link_subnet_name            = var.private_link_subnet_name
  add_local_host_entry                = true
  outbound_vnet_integration_subnet_id = var.web_app_outbound_vnet_integration_subnet_id
  enable_application_insights         = true
  application_insights_workspace_id   = module.log_analytics_workspace.id

  depends_on = [
    module.key_vault.id
  ]

}

resource "azurerm_role_assignment" "functionapp_to_storage" {
  for_each = { for k, v in module.function_app : k => v.system_managed_identity_id }

  scope                = module.storage_account.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "webapp_to_storage" {
  for_each = { for k, v in module.web_app : k => v.system_managed_identity_id }

  scope                = module.storage_account.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = each.value
}

# Eventhub Namespace
module "eventhub_instrumentation" {
  source = "../../../modules/azure/eventhub_namespace"
  providers = {
    azurerm.dns_forwarding = azurerm.dns
  }


  environment   = var.environment
  project_id    = var.project_id
  random_suffix = random_string.random_suffix.result

  resource_group_name = module.resource_group.name
  location            = var.location
  name_suffix         = "instrumentation"

  enable_private_link         = var.enable_private_link
  private_link_resource_group = var.private_link_resource_group
  private_link_vnet_name      = var.private_link_vnet_name
  private_link_subnet_name    = var.private_link_subnet_name
  add_private_dns_forwarding  = var.add_private_dns_forwarding
  add_local_host_entry        = var.add_local_host_entry
}

# SQL Server
module "azure_sql_server" {
  source = "../../../modules/azure/mssql_server"

  environment   = var.environment
  project_id    = var.project_id
  random_suffix = random_string.random_suffix.result
  location      = var.location

  resource_group_name = module.resource_group.name
  key_vault_id        = module.key_vault.id

  enable_private_link         = var.enable_private_link
  private_link_resource_group = var.private_link_resource_group
  private_link_vnet_name      = var.private_link_vnet_name
  private_link_subnet_name    = var.private_link_subnet_name
  add_local_host_entry        = var.add_local_host_entry

}

# SQL DBs
module "azure_sql_dbs" {
  source   = "../../../modules/azure/mssql_server_database"
  for_each = { for k, v in var.sql_dbs : v.name_suffix => v }

  environment   = var.environment
  project_id    = var.project_id
  random_suffix = random_string.random_suffix.result

  server_id            = module.azure_sql_server.id
  name_suffix          = each.value.name_suffix
  sku_name             = each.value.sku_name
  storage_account_type = each.value.storage_account_type
}

# Service Bus
module "servicebus_namespace" {
  source = "../../../modules/azure/servicebus_namespace"
  providers = {
    azurerm.dns_forwarding = azurerm.dns
  }

  environment   = var.environment
  project_id    = var.project_id
  random_suffix = random_string.random_suffix.result
  location      = var.location

  resource_group_name = module.resource_group.name
  sku                 = "Premium"

  enable_private_link         = var.enable_private_link
  private_link_resource_group = var.private_link_resource_group
  private_link_vnet_name      = var.private_link_vnet_name
  private_link_subnet_name    = var.private_link_subnet_name
  add_private_dns_forwarding  = true
}

resource "azurerm_role_assignment" "adf_to_storage_account" {
  scope                = module.storage_account.id
  role_definition_name = "storage Blob Data Contributor"
  principal_id         = module.data_factory.managed_identity_object_id
}

#Event Grid System Topic
resource "azurerm_eventgrid_system_topic" "this" {
  name                   = "egst${var.project_id}${var.environment}${random_string.random_suffix.result}"
  resource_group_name    = module.resource_group.name
  location               = var.location
  source_arm_resource_id = azurerm_storage_account.steg.id
  topic_type             = "Microsoft.Storage.StorageAccounts"
  tags                   = var.tags
}

# Cosmos DB
module "cosmosdb_graph" {
  source = "../../../modules/azure/cosmosdb"

  environment   = var.environment
  project_id    = var.project_id
  random_suffix = random_string.random_suffix.result

  resource_group_name = module.resource_group.name
  location            = var.location
  cosmosdb_api        = "graph"
  enable_serverless   = true

  enable_private_link         = true
  private_link_resource_group = var.private_link_resource_group
  private_link_vnet_name      = var.private_link_vnet_name
  private_link_subnet_name    = var.private_link_subnet_name
  add_local_host_entry        = true

}

resource "azurerm_synapse_managed_private_endpoint" "storage_account" {
  for_each             = { for k, v in ["blob", "dfs"] : k => v }
  name                 = "mpe-${module.synapse_workspace.name}-to-${module.storage_account.name}-${each.value}"
  synapse_workspace_id = module.synapse_workspace.id
  target_resource_id   = module.storage_account.id
  subresource_name     = each.value
}

resource "null_resource" "endpoint_approval_synapse_to_storage_arm" {
  for_each = { for k, v in azurerm_synapse_managed_private_endpoint.storage_account : k => v.name }
  provisioner "local-exec" {
    command     = <<-EOT
          az login --service-principal -u ${data.azurerm_client_config.current.client_id} -p ${data.azurerm_key_vault_secret.platfrom_sp.value} --tenant ${data.azurerm_client_config.current.tenant_id}
          $func_id = $(az network private-endpoint-connection list --id ${module.storage_account[each.key].id} --query "[?contains(name, '${each.value}')].id" --subscription ${data.azurerm_client_config.current.subscription_id} -o json) | ConvertFrom-Json
          az network private-endpoint-connection approve --id $func_id --description "Approved in Terraform" --subscription ${data.azurerm_client_config.current.subscription_id}
        EOT
    interpreter = ["pwsh", "-Command"]
  }
  depends_on = [azurerm_synapse_managed_private_endpoint.storage_account]
}
#########################################################################################     END     #########################################################################################





## testing 
resource "azurerm_data_factory_managed_private_endpoint" "func" {
  for_each           = { for k, v in module.function_app : k => v }
  name               = "mpe-${module.data_factory.name}-to-${each.value.name}"
  data_factory_id    = module.data_factory.id
  target_resource_id = each.value.id
  subresource_name   = "sites"
}

resource "null_resource" "endpoint_approval_adf_to_func_arm" {
  for_each = { for k, v in azurerm_data_factory_managed_private_endpoint.func : k => v.name }
  provisioner "local-exec" {
    command     = <<-EOT
          az login --service-principal -u ${data.azurerm_client_config.current.client_id} -p ${data.azurerm_key_vault_secret.platfrom_sp.value} --tenant ${data.azurerm_client_config.current.tenant_id}
          $func_id = $(az network private-endpoint-connection list --id ${module.function_app[each.key].id} --query "[?contains(name, '${each.value}')].id" --subscription ${data.azurerm_client_config.current.subscription_id} -o json) | ConvertFrom-Json
          az network private-endpoint-connection approve --id $func_id --description "Approved in Terraform" --subscription ${data.azurerm_client_config.current.subscription_id}
        EOT
    interpreter = ["pwsh", "-Command"]
  }
  depends_on = [azurerm_data_factory_managed_private_endpoint.func]
}

