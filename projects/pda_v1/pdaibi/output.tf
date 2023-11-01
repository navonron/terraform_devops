#### Outputs from Resources group modules #####
output "subscription_id" {
  value       = module.resource_group.subscription_id
  description = "Subscription id."
}
# Resource Group
output "resource_group_name" {
  value       = module.resource_group.name
  description = "Name of the resource group."
}


# KeyVault
output "key_vault_name" {
  value       = module.key_vault.name
  description = "Name of the Key Vault. Available only if `create_key_vault` is enabled."

}

output "key_vault_id" {
  value       = module.key_vault.id
  description = "ID of the Key Vault. Available only if `create_key_vault` is enabled."
}

output "key_vault_private_endpoint_custom_dns_configs" {
  value       = module.key_vault.private_endpoint_custom_dns_configs
  description = "Private Endpoint custom DNS Config of the Keyvault. Map of FQDN and IP address. Note: You need to request the Network team to add this FQDN and IP address in Intel DNS lookup server. Available only if `create_key_vault` and `enable_private_link_key_vault` is enabled."
}

# Log Analytics
output "log_analytics_name" {
  value       = module.log_analytics_workspace.name
  description = "Name of the Log Analytics Workspace."
}

output "log_analytics_id" {
  value       = module.log_analytics_workspace.id
  description = "Name of the Log Analytics Workspace."
}

output "log_analytics_workspace_id" {
  value       = module.log_analytics_workspace.workspace_id
  description = "The Workspace (or Customer) ID for the Log Analytics Workspace."
}

# Azure Data Factory
output "data_factory_name" {
  value       = module.data_factory.name
  description = " The Name of the Azure Data factory."
}

output "data_factory_id" {
  value       = module.data_factory.id
  description = " The ID of the Azure Data factory."
}

output "data_factory_managed_identity_object_id" {
  value       = module.data_factory.managed_identity_object_id
  description = "Azure Data factory Managed identity id"

}

output "data_factory_private_endpoint_custom_dns_configs" {
  value       = module.data_factory.private_endpoint_custom_dns_configs
  description = "The custom dns config for the private endpoint. Note: You need to raise a separate request to add this FDQN and IPs in Intel DNS records."
}

# Azure Disk Encryption Set
output "disk_encryption_set_id" {
  value       = module.disk_encryption_set.id
  description = "ID of the disk encryption set."
}

# Azure Data Factory SHIR VM
output "shir_virtual_machine_name" {
  value       = module.virtual_machine_windows.name
  description = "Name of the ADF SHIR Windows Virtual Machine."
}

output "shir_virtual_machine_id" {
  value       = module.virtual_machine_windows.id
  description = "ID of the ADF SHIR Windows Virtual Machine."
}

output "shir_virtual_machine_private_ip_address" {
  value       = module.virtual_machine_windows.private_ip_address
  description = "The Primary Private IP Address assigned to this Virtual Machine."
}

output "shir_virtual_machine_principal_id" {
  value       = module.virtual_machine_windows.principal_id
  description = "The Principal ID associated with this Managed Service Identity."
}

output "shir_virtual_machine_admin_username" {
  value       = module.virtual_machine_windows.admin_username
  description = "The username of the Windows Virtual Machine."
}

output "shir_virtual_machine_key_vault_secret_id" {
  value       = module.virtual_machine_windows.key_vault_secret_id
  description = "ID of the SQL Admin user `cdaadmin` password Keyvault Secret."
}

# # Databricks
# output "databricks_workspace_name" {
#   value       = module.databricks.name
#   description = " The Name of the Databricks workspace."
# }

# output "databricks_workspace_management_id" {
#   value       = module.databricks.id
#   description = "The ID of the Databricks Workspace in the Azure management plane."
# }

# output "databricks_workspace_url" {
#   value       = module.databricks.workspace_url
#   description = "The workspace URL which is of the format 'adb-{workspaceId}.{random}.azuredatabricks.net'."

# }

# output "databricks_workspace_id" {
#   value       = module.databricks.workspace_id
#   description = "The unique identifier of the databricks workspace in Databricks control plane."
# }

# output "databricks_private_endpoint_custom_dns_configs" {
#   value       = module.databricks.private_endpoint_custom_dns_configs
#   description = "The custom dns config for the private endpoint. Note: If `var.add_private_dns_forwarding` is not enabled, then You need to request the Network team to add this FQDN and IP address in Intel DNS lookup server. Available only if `enable_private_link` is enabled."
# }

# Synpase Workspace
output "synapse_workspace_name" {
  value       = module.synapse_workspace.name
  description = "Name of the Synapse Workspace."
}

output "synapse_workspace_id" {
  value       = module.synapse_workspace.id
  description = "ID of the Synapse Workspace."
}

output "synapse_workspace_managed_identity_object_id" {
  value       = module.synapse_workspace.managed_identity_object_id
  description = "Object ID of the Synapse workspace Managed Identity."
}

output "synapse_workspace_connectivity_endpoints" {
  value       = module.synapse_workspace.connectivity_endpoints
  description = "A list of Connectivity endpoints for this Synapse Workspace."
}

output "synapse_workspace_key_vault_secret_id" {
  value       = module.synapse_workspace.key_vault_secret_id
  description = "ID of the SQL Admin user `cdaadmin` password Keyvault Secret."
}

output "synapse_workspace_private_endpoint_custom_dns_config" {
  value       = module.synapse_workspace.private_endpoint_custom_dns_config
  description = "The custom dns config for the Synapse Workspace private endpoint. Note: You need to raise a separate request to add this FDQN and IPs in Intel DNS records."
}

output "synapse_workspace_storage_account_private_endpoint_custom_dns_config" {
  value       = module.synapse_workspace.storage_account_private_endpoint_custom_dns_config
  description = "The custom dns config for the Storage Account private endpoint managed by synpase workspace. Note: You need to raise a separate request to add this FDQN and IPs in Intel DNS records."
}
# Synapse Dedicated SQL Pool
output "synapse_sql_pool_name" {
  value       = module.synapse_sql_pool.name
  description = "Name of the Synapse Dedicated SQL Pool."
}

output "synapse_sql_pool_id" {
  value       = module.synapse_sql_pool.id
  description = "ID of the Synapse Dedicated SQL Pool."
}

# Service plan
output "service_plan_name" {
  value       = module.service_plan.name
  description = "Name of the App Service plan."
}

output "service_plan_id" {
  value       = module.service_plan.id
  description = "ID of the App Service Plan."
}

# Webapp
output "webapps" {
  value       = module.web_app
  description = "List of all the webapp output objects"
}

# Storage account (General)
output "storage_account_name" {
  value       = module.storage_account.name
  description = " The Name of the Storage Account."
}

output "storage_account_id" {
  value       = module.storage_account.id
  description = " The ID of the Storage Account."
}
output "storage_account_custom_dns_config" {
  value       = module.storage_account.private_endpoint_custom_dns_configs
  description = "The custom dns config for the private endpoint. Note: You need to raise a separate request to add this FDQN and IPs in Intel DNS records."
}

# Storage account (function app)
output "function_app_storage_account_name" {
  value       = module.function_app_storage_account.name
  description = " The Name of the Storage Account used by function app."
}

output "function_app_storage_account_id" {
  value       = module.function_app_storage_account.id
  description = " The ID of the Storage Account used by function app."
}
output "function_app_storage_account_custom_dns_config" {
  value       = module.function_app_storage_account.private_endpoint_custom_dns_configs
  description = "The custom dns config for the private endpoint. Note: You need to raise a separate request to add this FDQN and IPs in Intel DNS records."
}

# Function App

output "function_apps" {
  value       = module.function_app
  description = "List of the Function App output objects."
}

# # Cosmos DB
# output "cosmosdb_name" {
#   value       = module.cosmosdb_graph.name
#   description = "Name of the Cosmos DB Service."
# }

# output "cosmosdb_id" {
#   value       = module.cosmosdb_graph.id
#   description = "ID of the Cosmos DB."
# }

# output "cosmosdb_endpoint" {
#   value       = module.cosmosdb_graph.endpoint
#   description = "The endpoint used to connect to the CosmosDB account."
# }

# output "cosmosdb_system_managed_identity_id" {
#   value       = module.cosmosdb_graph.system_managed_identity_id
#   description = "The Principal ID associated with this Managed Service Identity of the Cosmos DB."
# }

# output "cosmosdb_private_endpoint_custom_dns_configs" {
#   value       = module.cosmosdb_graph.private_endpoint_custom_dns_configs
#   description = <<EOT
#   The custom dns config for the private endpoint.
  
#   Note: You need to raise a separate request to add this FDQN and IPs in Intel DNS records.
#   EOT
# }

# Eventhub namespace
output "eventhub_instrumentation_name" {
  value       = module.eventhub_instrumentation.name
  description = " The Name of the Eventhub namespace."
}

output "eventhub_instrumentation_id" {
  value       = module.eventhub_instrumentation.id
  description = " The ID of the Eventhub namespace."
}

output "eventhub_instrumentation_managed_identity_object_id" {
  value       = module.eventhub_instrumentation.managed_identity_object_id
  description = "Object ID of the Eventhub namespace Managed Identity."

}

output "eventhub_instrumentation_private_endpoint_custom_dns_configs" {
  value       = module.eventhub_instrumentation.private_endpoint_custom_dns_configs
  description = "The custom dns config for the private endpoint. Note: You need to raise a separate request to add this FDQN and IPs in Intel DNS records."
}

# Azure SQL Server
output "azure_sql_server_name" {
  value       = module.azure_sql_server.name
  description = "Name of the Azure SQL Server."
}

output "azure_sql_server_id" {
  value       = module.azure_sql_server.id
  description = "ID of the Azure SQL Server."
}

output "azure_sql_server_admin_username" {
  value       = module.azure_sql_server.admin_username
  description = "The administrator login name for the new server."
}

output "azure_sql_server_key_vault_secret_id" {
  value       = module.azure_sql_server.key_vault_secret_id
  description = "ID of the Azure SQL Server Admin user `var.administrator_login` password Keyvault Secret."
}

output "azure_sql_server_managed_identity_object_id" {
  value       = module.azure_sql_server.managed_identity_object_id
  description = "Object ID of the Azure SQL Server Managed Identity."

}

output "azure_sql_server_fully_qualified_domain_name" {
  value       = module.azure_sql_server.fully_qualified_domain_name
  description = "The fully qualified domain name of the Azure SQL Server (e.g. myServerName.database.windows.net)."
}

output "azure_sql_server_private_endpoint_custom_dns_configs" {
  value       = module.azure_sql_server.private_endpoint_custom_dns_configs
  description = "Private Endpoint custom DNS Config of the Azure SQL Server. Map of FQDN and IP address. Note: You need to request the Network team to add this FQDN and IP address in Intel DNS lookup server. Available only if `enable_private_link` is enabled."
}

# SQL Databases
output "sql_databases" {
  value = module.azure_sql_dbs
}

# Service bus
output "servicebus_name" {
  value       = module.servicebus_namespace.name
  description = " The Name of the Service Bus Namespace."
}

output "servicebus_id" {
  value       = module.servicebus_namespace.id
  description = " The ID of the Servicebus namespace."
}

output "servicebus_managed_identity_object_id" {
  value       = module.servicebus_namespace.managed_identity_object_id
  description = "Object ID of the Servicebus namespace Managed Identity."

}
output "servicebus_private_endpoint_custom_dns_configs" {
  value       = module.servicebus_namespace.private_endpoint_custom_dns_configs
  description = "The custom dns config for the private endpoint. Note: If `var.add_private_dns_forwarding` is not enabled, then You need to request the Network team to add this FQDN and IP address in Intel DNS lookup server. Available only if `enable_private_link` is enabled."
}