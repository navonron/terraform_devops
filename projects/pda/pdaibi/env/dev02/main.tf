data "azurerm_client_config" "current" {} ####SWITCH TO ENV VAR####

data "azuread_groups" "ad_groups" {
  display_names = [
    "Design-PDA-Azure-Developers",
    "Azure_Data_Platform_Admins"
  ]
}

data "azuread_service_principals" "service_principals" {
  display_names = [
    "sp_azure_data_platforms_pdaibi_dev",
    "ibi-daas-query-dev",
    "AzureDatabricks",
    "sp_AzureCloudDataPlatform_IaC_PP_IAP_25794",
    "synw-pdaibi-qa-dsag",
    "Azure Cosmos DB"
  ]
}

data "azurerm_virtual_network" "adb_vnet" {
  name                = "Azure-Analytics-Dev-Express-Route-Vnet-Adb-WestUs2"
  resource_group_name = "Azure-Product-Engineering-Analytics-Dev-Express-Route-Rg-WestUs2"
}

data "azurerm_subnet" "er_snet_001" {
  name                 = "Azure-Analytics-Dev-Express-Route-Subnet-WestUs2"
  virtual_network_name = "Azure-Analytics-Dev-Express-Route-Vnet-WestUs2"
  resource_group_name  = "Azure-Product-Engineering-Analytics-Dev-Express-Route-Rg-WestUs2"
}

data "azurerm_subnet" "er_snet_002" {
  name                 = "Azure-Analytics-Dev-Express-Route-Subnet2-WestUs2"
  virtual_network_name = "Azure-Analytics-Dev-Express-Route-Vnet-WestUs2"
  resource_group_name  = "Azure-Product-Engineering-Analytics-Dev-Express-Route-Rg-WestUs2"
}

data "azurerm_private_dns_zone" "intel_zone" {
  provider            = azurerm.shared
  name                = "privatelink.ibi.westus2.azmk8s.io"
  resource_group_name = "it_hub_shared_services"
}

module "dev" {
  source   = "../.."
  env      = "dev02"
  location = "westus2"
  prj_id   = "pdaibi"
  tags = {
    "infra-as-code" = "true"
    "iac-tool"      = "terraform"
    "environment"   = "dev02"
    "project_id"    = "pdaibi"
    "project_iap"   = "25794"
  }
  host_file_location       = "C:/Windows/System32/drivers/etc"
  custom_fqdn              = "privatelink.ibi.westus2.azmk8s.io"
  zone_rg                  = "it_hub_shared_services"
  zone_id                  = data.azurerm_private_dns_zone.intel_zone.id
  ttl                      = 3600
  tenant_id                = data.azurerm_client_config.current.tenant_id
  vnet_integration_snet_id = data.azurerm_subnet.er_snet_002.id
  pe_snet                  = data.azurerm_subnet.er_snet_001.id

  ### RESOURCE GROUPS ####
  rg = [{
    rbac = [{
      role = "Contributor"
      members = [
        data.azuread_groups.ad_groups.object_ids[0],
        data.azuread_service_principals.service_principals.object_ids[0]
      ]
    }]
  }]

  ### APP SERVICE PLAN ###
  asp = [{
    os  = "Windows"
    sku = "P1v2"
  }]

  ### STORAGE ACCOUNT ###
  sa = [
    {
      subresources = ["blob", "queue", "file", "table", "dfs"]
      is_hns       = true

      soft_delete_config = {
        container = 7
        blob      = 7
      }

      rbac = [
        {
          role = "Storage Blob Data Contributor"
          members = concat(
            [data.azuread_groups.ad_groups.object_ids[0]],
            [data.azuread_service_principals.service_principals.object_ids[0]],
            [data.azuread_service_principals.service_principals.object_ids[1]],
            [data.azuread_service_principals.service_principals.object_ids[2]]
          )
        },
        {
          role    = "Storage Blob Delegator"
          members = [data.azuread_service_principals.service_principals.object_ids[1]]
        },
        {
          role    = "Owner"
          members = [data.azuread_groups.ad_groups.object_ids[1]]
        }
      ]
    }
  ]

  ### WINDOWS WEB APP ###
  windows_web_app = [
    {
      workload = "adfhandler"
      stack    = "dotnet"
      version  = "v6.0"
      app_settings = {
        "WEBSITE_DNS_SERVER"       = "10.248.2.1"
        "WEBSITE_CONTENTOVERVNET"  = 1
        "WEBSITE_RUN_FROM_PACKAGE" = 1
      }
    },
    {
      workload = "collectionhelper"
      stack    = "dotnet"
      version  = "v6.0"
      app_settings = {
        "WEBSITE_DNS_SERVER"       = "10.248.2.1"
        "WEBSITE_CONTENTOVERVNET"  = 1
        "WEBSITE_RUN_FROM_PACKAGE" = 1
      }
    },
    {
      workload = "dbhandler"
      stack    = "dotnet"
      version  = "v6.0"
      app_settings = {
        "WEBSITE_DNS_SERVER"       = "10.248.2.1"
        "WEBSITE_CONTENTOVERVNET"  = 1
        "WEBSITE_RUN_FROM_PACKAGE" = 1
      }
    },
    {
      workload = "metadata"
      stack    = "dotnet"
      version  = "v6.0"
      app_settings = {
        "WEBSITE_DNS_SERVER"       = "10.248.2.1"
        "WEBSITE_CONTENTOVERVNET"  = 1
        "WEBSITE_RUN_FROM_PACKAGE" = 1
      }
    },
    {
      workload = "sdkdoc"
      stack    = "dotnet"
      version  = "v6.0"
      app_settings = {
        "WEBSITE_DNS_SERVER"       = "10.248.2.1"
        "WEBSITE_CONTENTOVERVNET"  = 1
        "WEBSITE_RUN_FROM_PACKAGE" = 1
      }
    },
    {
      workload      = "sso"
      stack         = "dotnet"
      version       = "v6.0"
      app_settings = {
        "WEBSITE_DNS_SERVER"       = "10.248.2.1"
        "WEBSITE_CONTENTOVERVNET"  = 1
        "WEBSITE_RUN_FROM_PACKAGE" = 1
      }
    },
    {
      workload = "storage"
      stack    = "dotnet"
      version  = "v6.0"
      app_settings = {
        "WEBSITE_DNS_SERVER"       = "10.248.2.1"
        "WEBSITE_CONTENTOVERVNET"  = 1
        "WEBSITE_RUN_FROM_PACKAGE" = 1
      }
    }
  ]

  ### WINDOWS FUNCTION APP ###
  windows_func = [
    {
      workload  = "arm"
      app_settings = {
        "WEBSITE_DNS_SERVER"       = "10.248.2.1"
        "WEBSITE_CONTENTOVERVNET"  = 1
        "WEBSITE_RUN_FROM_PACKAGE" = 1
      }
      stack = {
        is_custom_runtime = true
      }
    },
    {
      workload  = "collectionflow"
      app_settings = {
        "WEBSITE_DNS_SERVER"       = "10.248.2.1"
        "WEBSITE_CONTENTOVERVNET"  = 1
        "WEBSITE_RUN_FROM_PACKAGE" = 1
      }
      stack = {
        is_custom_runtime = true
      }
    },
    {
      workload  = "policyorch"
      app_settings = {
        "WEBSITE_DNS_SERVER"       = "10.248.2.1"
        "WEBSITE_CONTENTOVERVNET"  = 1
        "WEBSITE_RUN_FROM_PACKAGE" = 1
      }
      stack = {
        is_custom_runtime = true
      }
      slots = [{
        add_vnet_integration = true
      }]
    },
    {
      workload  = "persistence"
      app_settings = {
        "WEBSITE_DNS_SERVER"       = "10.248.2.1"
        "WEBSITE_CONTENTOVERVNET"  = 1
        "WEBSITE_RUN_FROM_PACKAGE" = 1
      }
      stack = {
        is_custom_runtime = true
      }
    }
  ]

  ### EVENT HUB NAMESPACE ###
  eventhub_ns = [{
    workload = "instrumentation"
    sku      = "Standard"

    acess_policies = [
      {
        name    = "WriteAccessKey"
        is_send = true
      },
      {
        name      = "LogstashAccessKey"
        is_listen = true
      }
    ]

    instances = [
      {
        name = "databricks-sql-queries"
        auth_rule = {
          name      = "LogstashListen"
          is_listen = true
        }
      },
      {
        name            = "databricks_diagnostic"
        partition_count = 4
        msg_retention   = 7
      },
      {
        name = "ibi_instrumentation"
        auth_rule = {
          name      = "LogstashListen"
          is_listen = true
        }
      },
      {
        name = "testing"
      },
    ]
  }]

  ### KEY VAULT ###
  kv = [{
    rbac = [{
      role = "Key Vault Administrator"
      members = [
        data.azuread_groups.ad_groups.object_ids[0],
        data.azuread_service_principals.service_principals.object_ids[0],
        data.azuread_service_principals.service_principals.object_ids[5]
      ]
    }]
  }]

  ### SQL ###
  sql = [{
    version            = "12.0"
    admin_user         = "sys_sql_admin"
    ad_admin_user      = data.azuread_groups.ad_groups.display_names[0]
    ad_admin_object_id = data.azuread_groups.ad_groups.object_ids[0]

    dbs = [
      {
        workload = "persistence"
        sku      = "Basic"
        sa_type  = "Zone"
      },
      {
        workload = "efcore"
        sku      = "Basic"
        sa_type  = "Zone"
      },
      {
        workload = "report"
        sku      = "Basic"
      }
    ]
  }]

  ### SERVICEBUS NAMESPACE ###
  servicebus_ns = [{
    sku      = "Premium"
    capacity = 1

    queues = [
      {
        name = "data_updated"
      },
      {
        name = "etl-local-queue"
      },
      {
        name = "ingestion-local-queue"
      },
      {
        name = "ingestion-queue"
      },
      {
        name = "reporting-local-queue"
      },
      {
        name = "reporting-queue"
      }
    ]

    topics = [
      {
        name = "data_updated_topic"
        subscriptions = [
          {
            name = "reporting"
          },
          {
            name = "transformation"
          }
        ]
      },
      {
        name = "ibi_instrumentation_sb"
      }
    ]
  }]

  ### DATA FACTORY ###
  # adf = [{}]

  ### EVENTGRID SYSTEM TOPIC ###
  eventgrid_sys_topic = [{
    type = "Microsoft.Storage.StorageAccounts"
  }]

  ### COSMOS DB ACCOUNT ###
  cosmosdb = [{
    kind             = "GlobalDocumentDB"
    throughput_limit = -1
    capabilities     = ["EnableGremlin"]
    subresources     = ["Sql", "Gremlin"]

    consistency = {
      level = "Session"
    }

    backup = {
      type                = "Periodic"
      interval_in_minutes = 240
      retention_in_hours  = 24
      storage_redundancy  = "Local"
    }
  }]

  ### DATABRICKS ###
  databricks = [{
    sku       = "premium"
    vnet_config = {
      vnet_id = data.azurerm_virtual_network.adb_vnet.id

      public_snet = {
        workload  = "adb"
        vnet_name = "Azure-Analytics-Dev-Express-Route-Vnet-Adb-WestUs2"
        vnet_rg   = "Azure-Product-Engineering-Analytics-Dev-Express-Route-Rg-WestUs2"
        ip_range  = "10.139.50.0/25"

        delegation = {
          actions = [
            "Microsoft.Network/virtualNetworks/subnets/join/action",
            "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
            "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
          ]
          service_delegation = "Microsoft.Databricks/workspaces"
        }
      }

      private_snet = {
        workload  = "adb"
        vnet_name = "Azure-Analytics-Dev-Express-Route-Vnet-Adb-WestUs2"
        vnet_rg   = "Azure-Product-Engineering-Analytics-Dev-Express-Route-Rg-WestUs2"
        ip_range  = "10.139.50.128/25"

        delegation = {
          actions = [
            "Microsoft.Network/virtualNetworks/subnets/join/action",
            "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
            "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
          ]
          service_delegation = "Microsoft.Databricks/workspaces"
        }
      }
    }
  }]

  ### SYNAPSE ###
  synapse = [{
    admin_user          = "cdaadmin"
    subresources        = ["Sql", "SqlOnDemand", "Dev"]
    aad_admin_object_id = data.azuread_groups.ad_groups.object_ids[1]

    sa = {
      workload     = "synw"
      subresources = ["blob", "queue", "file", "table", "dfs"]
    }

    synapse_sql_pool = {
      sku         = "DW100c"
      create_mode = "Default"
      collation   = "SQL_LATIN1_GENERAL_CP1_CI_AS"
    }

    # synapse_role = [{
    #   role = "Synapse Administrator"
    #   principal_ids = [
    #     data.azuread_groups.ad_groups.object_ids[0],
    #     data.azuread_groups.ad_groups.object_ids[1],
    #     data.azuread_service_principals.service_principals.object_ids[3],
    #     data.azuread_service_principals.service_principals.object_ids[4]
    #   ]
    # }]
  }]
}
