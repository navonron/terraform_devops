# Default Generic Variables
variable "environment" {
  type        = string
  description = "Allowed environment values are poc, sbox, bsox, dev, qa, prod, dr. Max 4 chars."

  validation {
    condition     = contains(["poc", "sbox", "bsox", "dev", "qa", "prod", "dr"], var.environment)
    error_message = "The environment value should be one among ['poc', 'sbox', 'bsox', 'dev', 'qa', 'prod', 'dr']."
  }
}

variable "subscription_id" {
  type        = string
  description = "Subscription id"
}

variable "project_id" {
  type        = string
  description = "Short project identifier. Max 6 chars."

  validation {
    condition     = length(var.project_id) <= 6
    error_message = "Max 6 characters are allowed."
  }
}

variable "project_iap" {
  type        = string
  description = "IAP number of the project"
}

variable "location" {
  type        = string
  description = "Default location where all the resources need to be created."
}
variable "tags" {
  type        = map(any)
  description = "Tags to be added to all the resources."
  default     = {}
}

# AAD Entitlement Variable
variable "entitlement_lookup" {
  type        = map(string)
  description = "Key value pair of Identifiable Name and valid Active Directory Object id."
}

# Express route specific variables
variable "private_link_resource_group" {
  type        = string
  description = "Resource group name where express route Vnet for private endpoint is hosted. Valid only if `enable_private_link_key_vault` variable is enabled."
  default     = ""
}

variable "private_link_vnet_name" {
  type        = string
  description = "Name of the Express Route Virtual Network for private endpoint. Valid only if `enable_private_link_key_vault` variable is enabled."
  default     = ""
}

variable "private_link_subnet_name" {
  type        = string
  description = "Name of the Subnet under Express Route Virtual Network for private endpoint. Valid only if `enable_private_link_key_vault` variable is enabled."
  default     = ""
}

# Resource Group Specific Variable
variable "resource_group_access_mapping" {
  type        = map(list(string))
  description = "Map of Azure Resource Group RBAC roles as key and list of Azure Active Directory objects as value. Note: It works only together with variable: entitlement_lookup."
}

# Key Vault specific Variables

variable "key_vault_access_mapping" {
  type        = map(list(string))
  default     = {}
  description = "Map of Azure Key Vault RBAC roles as key and list of Azure Active Directory objects as value.  Note: It works only together with variable: entitlement_lookup."

}

# Datafactory Variables
variable "datafactory_enable_diagnostic_setting" {
  type        = bool
  description = "(optional) Check whether diagnostic settings needs to be enabled for the datafactory. If enabled, variable `datafactory_enable_diagnostic_setting` must be provided."
  default     = false
}

variable "datafactory_log_retention_days" {
  type        = number
  description = "(optional) Number of days the logs needs to be retained in the log analytics workspace. Default value is 90 days. Give 0 to retain the logs forever. Note: This field is used only when `datafactory_enable_diagnostic_setting` is enabled."
  default     = 90
}

# Azure VM for Data Factory SHIR
variable "shir_windows_vm_size" {
  type        = string
  description = "(optional) The SKU which should be used for this ADF SHIR Virtual Machine, such as `Standard_F2`."
  default     = "Standard_D2s_v3"
}

variable "shir_windows_vm_sku" {
  type        = string
  description = "(optional) Specifies the SKU of the image used to create the ADF SHIR virtual machines."
  default     = "2019-Datacenter"
}

# Databricks Workspace Variables
variable "databricks_vnet_resource_group" {
  type        = string
  description = "Resource group name where express route Vnet for databricks is hosted. If not provided, it will try to use `private_link_resource_group` variable."
  default     = ""
}

variable "databricks_vnet_name" {
  type        = string
  description = "(required) Name of the Express Route Virtual Network for Databricks. Terraform will automatically create subnets in this vnet."
}

variable "databricks_public_subnet_address_prefix" {
  type        = string
  description = "(required) Address prefix of the public subnet. eg: If the virtual network address space is 10.20.30.0/25, then public subnet address prefix can be 10.20.30.0/26."
}

variable "databricks_private_subnet_address_prefix" {
  type        = string
  description = "(required) Address prefix of the private subnet. eg: If the virtual network address space is 10.20.30.0/25, then private subnet address prefix can be 10.20.30.64/26."
}
variable "databricks_public_network_access_enabled" {
  type        = bool
  description = "(Optional) Is the Databricks Workspace accessible in the public network? Defaults to true. Once its enabled, it can not be disabled. For the new databricks workspaces, we recommand to set enable_private_link to true and public_network_access_enabled to false."
  default     = true
}
variable "databricks_enable_private_link" {
  type        = bool
  default     = true
  description = "Boolean flag to enable private link endpoint for the Databricks Workspace. If enabled, 3 variables namely `private_link_resource_group`, `private_link_vnet_name` and `private_link_subnet_name` should be provided."
}
# Synapse Variable
variable "synapse_workspace_access_mapping" {
  type        = map(list(string))
  default     = {}
  description = <<-EOT
  Map of Azure synapse_workspace RBAC roles as key and list of Azure Active Directory objects as value.  Note: It works only together with variable: entitlement_lookup.
  Currently, the Synapse built-in roles are Apache Spark Administrator, Synapse Administrator, Synapse Artifact Publisher, Synapse Artifact User, Synapse Compute Operator, Synapse Contributor, Synapse Credential User, Synapse Linked Data Manager, Synapse SQL Administrator and Synapse User.
  
  EOT
}

variable "synapse_sku_name" {
  type        = string
  description = "Specifies the SKU Name for this Synapse Sql Pool. Possible values are DW100c, DW200c, DW300c, DW400c, DW500c, DW1000c, DW1500c, DW2000c, DW2500c, DW3000c, DW5000c, DW6000c, DW7500c, DW10000c, DW15000c or DW30000c. Note: This change will be applied only on the first time. If any update made to this resources will be ignored."
  default     = "DW100c"
}

# Service plan
variable "service_plan_name_suffix" {
  type        = string
  default     = ""
  description = "(optional) Suffix to be added to the App Service Plan name. Use this only when the default name derived by the terrafrom is not available. Max 8 chars."
  validation {
    condition     = length(var.service_plan_name_suffix) <= 8
    error_message = "Max 8 characters are allowed."
  }
}

variable "service_plan_os_type" {
  type        = string
  description = "(Required) The O/S type for the App Services to be hosted in this plan. Possible values include `Windows`, `Linux`, and `WindowsContainer`."

  validation {
    condition     = contains(["Windows", "Linux", "WindowsContainer"], var.service_plan_os_type)
    error_message = "The os_type value should be one among ['Windows', 'Linux', 'WindowsContainer']."
  }
}

variable "service_plan_sku_name" {
  type        = string
  default     = "P1v2"
  description = <<EOT
    (optional) The SKU for the plan. Possible values include B1, B2, B3, D1, F1, I1, I2, I3, I1v2, I2v2, I3v2, P1v2, P2v2, P3v2, P1v3, P2v3, P3v3, S1, S2, S3, SHARED, EP1, EP2, EP3, WS1, WS2, WS3, and Y1.

    NOTE:
      * Default value is: P1v2
      * Isolated SKUs (I1, I2, I3, I1v2, I2v2, and I3v2) can only be used with App Service Environments
      * Elastic and Consumption SKUs (Y1, EP1, EP2, and EP3) are for use with Function Apps.
  EOT
}

# Webapp
variable "web_app_runtime_version" {
  type        = string
  description = <<EOT
    (required) Web App runtime versions. Supported values are

    Valid versions list below are derived from the output of this commands `az webapp list-runtimes`.
    
    Format for linux: 
    * For Docker: <OS>|docker|
    * For Java: <OS>|<java version>|<Java Server>:<Java Server version>
    * For rest all: <OS>|<Stack>|<version>           
    Format for Windows: 
    * Dockers are not supported.
    * For Java: <OS>|java:<java version>|<Java Server>:<Java Server version>
    * For rest all: <OS>|<Stack>|<version>  

  Note: 
    * Platform team recommends using linux Service plan, especially for non dotnet stacks. So windows has very limitted support in this module.
    * If the runtime version starts with windows, then the app service plan should also be of os type windows.
    * These values are respected only at the first time of the deployment. Any updated to this field will be ignored.

  EOT

  validation {
    condition     = contains(["linux|docker", "linux|DOTNETCORE|7.0", "linux|DOTNETCORE|6.0", "linux|DOTNETCORE|3.1", "linux|NODE|18-lts", "linux|NODE|16-lts", "linux|NODE|14-lts", "linux|PYTHON|3.10", "linux|PYTHON|3.9", "linux|PYTHON|3.8", "linux|PYTHON|3.7", "linux|PHP|8.1", "linux|PHP|8.0", "linux|PHP|7.4", "linux|RUBY|2.7", "linux|java17|JAVA:17", "linux|java11|JAVA:11", "linux|jre8|JAVA:8", "linux|java11|JBOSSEAP:7", "linux|java8|JBOSSEAP:7", "linux|java17|TOMCAT:10.0", "linux|java11|TOMCAT:10.0", "linux|jre8|TOMCAT:10.0", "linux|java17|TOMCAT:9.0", "linux|java11|TOMCAT:9.0", "linux|jre8|TOMCAT:9.0", "linux|java11|TOMCAT:8.5", "linux|jre8|TOMCAT:8.5", "linux|GO|1.19", "linux|GO|1.18", "windows|dotnet|v7.0", "windows|dotnet|v6.0", "windows|dotnet|v5.0", "windows|dotnet|v4.0", "windows|dotnet|v3.0", "windows|dotnet|v2.0", "windows|dotnet|core3.1", "windows|NODE|16-LTS", "windows|java:1.8|Java:8"], var.web_app_runtime_version)
    error_message = "The valid values are ['linux|docker','linux|DOTNETCORE|7.0','linux|DOTNETCORE|6.0','linux|DOTNETCORE|3.1','linux|NODE|18-lts','linux|NODE|16-lts','linux|NODE|14-lts','linux|PYTHON|3.10','linux|PYTHON|3.9','linux|PYTHON|3.8','linux|PYTHON|3.7','linux|PHP|8.1','linux|PHP|8.0','linux|PHP|7.4','linux|RUBY|2.7','linux|java17|JAVA:17','linux|java11|JAVA:11','linux|jre8|JAVA:8','linux|java11|JBOSSEAP:7','linux|java8|JBOSSEAP:7','linux|java17|TOMCAT:10.0','linux|java11|TOMCAT:10.0','linux|jre8|TOMCAT:10.0','linux|java17|TOMCAT:9.0','linux|java11|TOMCAT:9.0','linux|jre8|TOMCAT:9.0','linux|java11|TOMCAT:8.5','linux|jre8|TOMCAT:8.5','linux|GO|1.19','linux|GO|1.18','windows|dotnet|v7.0','windows|dotnet|v6.0','windows|dotnet|v5.0','windows|dotnet|v4.0','windows|dotnet|v3.0','windows|dotnet|v2.0','windows|dotnet|core3.1','windows|NODE|16-LTS','windows|java:1.8|Java:8']"
  }
}

variable "web_app_outbound_vnet_integration_subnet_id" {
  type        = string
  description = <<-EOT
  (Required) The ID of the subnet the app service will be associated to (the subnet must have a service_delegation configured for Microsoft.Web/serverFarms).

    Note: 
      * There is a hard limit of one VNet integration per App Service Plan. Multiple apps in the same App Service plan can use the same VNet.
      * This subnet must be already delegated to Microsoft.Web/serverFarms.
  EOT
  default     = ""
}

# Storage Account (common for all storage accounts)
variable "storage_account_replication_type" {
  type        = string
  description = "(Required) Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS. Changing this forces a new resource to be created when types LRS, GRS and RAGRS are changed to ZRS, GZRS or RAGZRS and vice versa. Consider using RAGRS/RAGZRS in PROD environment."
  default     = "GRS"

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.storage_account_replication_type)
    error_message = "Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS."
  }
}

variable "storage_account_access_mapping" {
  type        = map(list(string))
  default     = {}
  description = "Map of Azure Storage Account RBAC roles as key and list of Azure Active Directory objects as value.  Note: It works only together with variable: entitlement_lookup."
}

# Function App
variable "function_app_runtime_version" {
  type        = string
  description = <<EOT
    (required) Function App runtime versions. All the supported values can be found in the readme.md. 

  Note: If the runtime version starts with windows, then the app service plan should also be of os type windows.

  EOT

  validation {
    condition     = contains(["linux|docker|", "linux|DOTNET-ISOLATED|7.0", "linux|DOTNET-ISOLATED|6.0", "linux|DOTNET|6.0", "linux|DOTNET|3.1", "linux|Node|18", "linux|Node|16", "linux|Node|14", "linux|Node|12", "linux|Python|3.9", "linux|Python|3.8", "linux|Python|3.7", "linux|Java|17", "linux|Java|11", "linux|Java|8", "linux|PowerShell|7.2", "linux|PowerShell|7", "windows|DOTNET-ISOLATED|7", "windows|DOTNET-ISOLATED|6", "windows|DOTNET|v6.0", "windows|DOTNET|v7.0", "windows|Node|18", "windows|Node|16", "windows|Node|14", "windows|Node|12", "windows|Java|17", "windows|Java|11", "windows|Java|8", "windows|PowerShell|7.2", "windows|PowerShell|7.0", "windows|custom"], var.function_app_runtime_version)
    error_message = "The valid values are ['linux|docker|','linux|DOTNET-ISOLATED|7.0','linux|DOTNET-ISOLATED|6.0','linux|DOTNET|6.0','linux|DOTNET|3.1','linux|Node|18','linux|Node|16','linux|Node|14','linux|Node|12','linux|Python|3.9','linux|Python|3.8','linux|Python|3.7','linux|Java|17','linux|Java|11','linux|Java|8','linux|PowerShell|7.2','linux|PowerShell|7','windows|DOTNET-ISOLATED|7','windows|DOTNET-ISOLATED|6','windows|DOTNET|v6.0','windows|DOTNET|v7.0','windows|Node|18','windows|Node|16','windows|Node|14','windows|Node|12','windows|Java|17','windows|Java|11','windows|Java|8','windows|PowerShell|7.2','windows|PowerShell|7.0','windows|custom']"
  }
}

variable "enable_private_link" {
  type        = bool
  default     = true
  description = "Boolean flag to enable private link endpoint for the storage account. If enabled, 3 variables namely `private_link_resource_group`, `private_link_vnet_name` and `private_link_subnet_name` should be provided."
}
variable "add_private_dns_forwarding" {
  type        = bool
  default     = true
  description = "(optional) Boolean flag to add the private endpoint IP and FDQN to the Central Azure Private DNS zone managed by the Cloud Brokers. Note: It works only together with variable: enable_private_link."
}
variable "add_local_host_entry" {
  type        = bool
  default     = true
  description = "(optional) Boolean flag to add the private endpoint IP and FDQN to the local hosts file. enable_private_link Note: It works only together with variable: enable_private_link."
}

# Objects
variable "sql_dbs" {
  type = list(object({
    name_suffix          = string
    sku_name             = string
    storage_account_type = optional(string, "Geo")
  }))
  description = "(optional) SQL database name suffix with SKU name."
}
