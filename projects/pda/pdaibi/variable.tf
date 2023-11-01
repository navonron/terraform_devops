variable "env" { type = string }
variable "prj_id" { type = string }
variable "location" { type = string }
variable "tags" { type = map(string) }
variable "host_file_location" { type = string }
variable "custom_fqdn" { type = string }
variable "zone_rg" { type = string }
variable "zone_id" { type = string }
variable "ttl" { type = number }
variable "tenant_id" { type = string }
variable "vnet_integration_snet_id" { type = string }
variable "pe_snet" { type = string }

variable "rg" {
  type = list(object({
    workload = optional(string, "")

    rbac = list(object({
      role    = string
      members = list(string)
    }))
  }))
}

variable "asp" {
  type = list(object({
    os          = string
    sku         = string
    workload    = optional(string, "")
    tags        = optional(map(string), null)
    is_zrs      = optional(bool, false)
    max_elastic = optional(number, null)
    instances   = optional(number, 1)
  }))

  validation {
    condition = alltrue([for asp in var.asp :
      contains(["Windows", "Linux", "WindowsContainer"],
    asp.os)])
    error_message = "ASP os OPTIONS ARE - Windows, Linux, WindowsContainer"
  }

  validation {
    condition = alltrue([for asp in var.asp :
      contains(["B1", "B2", "B3", "D1", "F1",
        "I1", "I2", "I3", "I1v2", "I2v2", "I3v2", "I4v2", "I5v2", "I6v2",
        "P1v2", "P2v2", "P3v2", "P0v3", "P1v3", "P2v3", "P3v3",
        "P1mv3", "P2mv3", "P3mv3", "P4mv3", "P5mv3",
        "S1", "S2", "S3", "SHARED",
        "EP1", "EP2", "EP3", "WS1", "WS2", "WS3", "Y1"],
    asp.sku)])
    error_message = "ASP sku OPTIONS ARE - B1, B2, B3, D1, F1, I1, I2, I3, I1v2, I2v2, I3v2, I4v2, I5v2, I6v2, P1v2, P2v2, P3v2, P0v3, P1v3, P2v3, P3v3, P1mv3, P2mv3, P3mv3, P4mv3, P5mv3, S1, S2, S3, SHARED, EP1, EP2, EP3, WS1, WS2, WS3, Y1"
  }
}


variable "sa" {
  type = list(object({
    subresources     = list(string)
    workload         = optional(string, "")
    tags             = optional(map(string), null)
    kind             = optional(string, "StorageV2")
    tier             = optional(string, "Standard")
    redundancy       = optional(string, "GRS")
    is_nested_public = optional(bool, false)
    is_hns           = optional(bool, false)

    soft_delete_config = optional(object({
      container = optional(number, null)
      blob      = optional(number, null)
    }), null)

    networking = optional(object({
      allow_ips   = optional(list(string), null)
      allow_snets = optional(list(string), null)
    }), null)

    rbac = optional(list(object({
      role    = string
      members = list(string)
    })), null)

    lifecycle = optional(list(object({
      name                                          = string
      blob_types                                    = string
      prefix_match                                  = optional(list(string), null)
      delete_after_days_since_creation_greater_than = number
    })), null)
  }))

  validation {
    condition = alltrue([for sa in var.sa :
      contains(["BlobStorage", "BlockBlobStorage", "FileStorage", "Storage", "StorageV2"],
    sa.kind)])
    error_message = "SA kind OPTIONS ARE - BlobStorage, BlockBlobStorage, FileStorage, Storage, StorageV2"
  }

  validation {
    condition = alltrue([for sa in var.sa :
      contains(["Standard", "Premium"],
    sa.tier)])
    error_message = "SA tier OPTIONS ARE - Standard, Premium"
  }

  validation {
    condition = alltrue([for sa in var.sa :
      contains(["GRS", "RAGRS", "GZRS", "RAGZRS"],
    sa.redundancy)])
    error_message = "SA redundancy OPTIONS ARE - GRS, RAGRS, GZRS, RAGZRS"
  }
}

variable "windows_web_app" {
  type = list(object({
    workload     = string
    stack        = string
    version      = optional(string, null)
    app_settings = optional(map(string), null)

    docker_config = optional(object({
      image        = string
      registry_url = string
      username     = string
      password     = string
    }), null)

    rules = optional(list(object({
      action      = optional(string, "Deny")
      priority    = optional(number, null)
      allow_ip    = optional(string, null)
      allow_snet  = optional(string, null)
      service_tag = optional(string, null)
    })), null)

    rbac = optional(list(object({
      role    = string
      members = list(string)
    })), null)
  }))
}

variable "windows_func" {
  type = list(object({
    workload      = string
    app_settings  = optional(map(string), null)
    is_https_only = optional(bool, true)

    stack = object({
      dotnet_version          = optional(string, null)
      java_version            = optional(string, null)
      node_version            = optional(string, null)
      powershell_core_version = optional(string, null)
      is_custom_runtime       = optional(bool, false)
    })

    rules = optional(list(object({
      action      = optional(string, "Deny")
      priority    = optional(number, null)
      allow_ip    = optional(string, null)
      allow_snet  = optional(string, null)
      service_tag = optional(string, null)
    })), null)

    rbac = optional(list(object({
      role    = string
      members = list(string)
    })), null)

    slots = optional(list(object({
      workload             = optional(string, null)
      add_vnet_integration = optional(bool, false)
    })), null)
  }))
}

variable "eventhub_ns" {
  type = list(object({
    sku             = string
    workload        = optional(string, "")
    tags            = optional(map(string), null)
    capacity        = optional(number, null)
    is_auto_inflate = optional(bool, false)
    is_zrs          = optional(bool, false)
    is_local_auth   = optional(bool, true)
    max_throughput  = optional(number, null)

    networking = optional(object({
      allow_snets            = optional(list(string), [])
      ips_mask               = optional(list(string), [])
      ips_mask_action        = optional(string, "Deny")
    }), null)

    acess_policies = optional(list(object({
      name      = string
      is_listen = optional(bool, false)
      is_send   = optional(bool, false)
      is_manage = optional(bool, false)
    })), null)

    instances = optional(list(object({
      name            = string
      partition_count = optional(number, 1)
      msg_retention   = optional(number, 1)
      auth_rule = optional(object({
        name      = string
        is_listen = optional(bool, false)
        is_send   = optional(bool, false)
        is_manage = optional(bool, false)
      }), null)
    })), null)

    rbac = optional(list(object({
      role    = string
      members = list(string)
    })), null)
  }))
}

variable "kv" {
  type = list(object({
    workload           = optional(string, "")
    tags               = optional(map(string), null)
    is_rbac_auth       = optional(bool, true)
    is_disk_encryption = optional(bool, true)
    soft_delete_days   = optional(number, 7)

    networking = optional(object({
      bypass      = optional(string, null)
      allow_ips   = optional(list(string), [])
      allow_snets = optional(list(string), [])
    }), null)

    rbac = optional(list(object({
      role    = string
      members = list(string)
    })), null)
  }))
}

variable "sql" {
  type = list(object({
    version              = string
    admin_user           = string
    tags                 = optional(map(string), null)
    workload             = optional(string, "")
    connection_policy    = optional(string, "Default")
    ad_admin_user        = optional(string, null)
    ad_admin_object_id   = optional(string, null)
    is_outbound_restrict = optional(bool, false)

    dbs = optional(list(object({
      workload     = optional(string, "")
      create_mode  = optional(string, "Default")
      sku          = string
      max_size_gb  = optional(number, null)
      min_capacity = optional(number, null)
      sa_type      = optional(string, "Geo")
      license      = optional(string, "LicenseIncluded")

      short_term_backup_config = optional(object({
        retention_days           = optional(number, null)
        backup_interval_in_hours = optional(number, null)
      }), null)

      long_term_backup_config = optional(object({
        weekly_retention  = optional(string, null)
        monthly_retention = optional(string, null)
        yearly_retention  = optional(string, null)
        week_of_year      = optional(number, null)
      }), null)
    })), [])
  }))
}

variable "servicebus_ns" {
  type = list(object({
    sku           = string
    workload      = optional(string, "")
    tags          = optional(map(string), null)
    capacity      = optional(number, null)
    is_local_auth = optional(bool, true)
    is_zrs        = optional(bool, false)

    networking = optional(object({
      trusted_service_access = optional(bool, true)
      allow_ips              = optional(list(string), [])
      allow_snets            = optional(list(string), [])
    }), null)

    queues = optional(list(object({
      name            = string
      is_partitioning = optional(bool, false)
    })), null)

    topics = optional(list(object({
      name            = string
      is_partitioning = optional(bool, false)
      subscriptions = optional(list(object({
        name               = string
        max_delivery_count = optional(number, 2000)
      })), null)
    })), null)

    rbac = optional(list(object({
      role    = string
      members = list(string)
    })), null)
  }))
}

variable "eventgrid_sys_topic" {
  type = list(object({
    type     = string
    workload = optional(string, "")
    tags     = optional(map(string), null)

    subscriptions = optional(list(object({
      name                        = string
      includ_events               = optional(list(string), null)
      is_array_advanced_filtering = optional(bool, false)
      max_delivery_attempt        = optional(number, 1)
      event_time_to_live          = optional(number, 1440)

      queue_ep = optional(object({
        name             = string
        sa_id            = string
        msg_time_to_live = optional(number, 604800)
      }), null)

      webhook_ep = optional(object({
        url                     = string
        max_events_per_batch    = optional(number, 1)
        preferred_batch_size_kb = optional(number, 64)
      }), null)

      advanced_filter = optional(object({
        string_ends_with = optional(object({
          key    = string
          value  = optional(string, null)
          values = optional(list(string), null)
        }), null)

        string_begins_with = optional(object({
          key    = string
          value  = optional(string, null)
          values = optional(list(string), null)
        }), null)

        string_not_in = optional(object({
          key    = string
          value  = optional(string, null)
          values = optional(list(string), null)
        }), null)

        number_greater_than = optional(object({
          key    = string
          value  = optional(string, null)
          values = optional(list(string), null)
        }), null)

        string_in = optional(object({
          key    = string
          value  = optional(string, null)
          values = optional(list(string), null)
        }), null)
      }), null)

      subject_filter = optional(object({
        begins_with = optional(string, null)
        ends_with   = optional(string, null)
      }), null)
    })), null)
  }))
}

variable "cosmosdb" {
  type = list(object({
    kind             = string
    subresources     = list(string)
    workload         = optional(string, "")
    tags             = optional(map(string), null)
    mongo_version    = optional(string, null)
    is_multi_write   = optional(bool, false)
    is_auto_fail     = optional(bool, false)
    is_local_auth    = optional(bool, false)
    allow_ips        = optional(string, null)
    allow_snets      = optional(list(string), [])
    throughput_limit = optional(number, null)
    capabilities     = optional(list(string), [])

    consistency = object({
      level                   = string
      max_interval_in_seconds = optional(number, null)
      max_staleness_prefix    = optional(number, null)
    })

    geo_location = optional(object({
      primary = optional(object({
        location       = string
        zone_redundant = optional(bool, false)
      }), null)
      secondary = optional(object({
        location       = string
        zone_redundant = optional(bool, false)
      }), null)
    }), null)

    backup = optional(object({
      type                = optional(string, null)
      interval_in_minutes = optional(string, null)
      retention_in_hours  = optional(string, null)
      storage_redundancy  = optional(string, null)
    }), null)
    create_mode = optional(string, null)

    rbac = optional(list(object({
      role    = string
      members = list(string)
    })), null)
  }))
}

variable "databricks" {
  type = list(object({
    sku             = string
    workload        = optional(string, "")
    tags            = optional(map(string), null)
    is_nsg_required = optional(string, null)
    add_pip         = optional(bool, false)

    vnet_config = optional(object({
      vnet_id = string

      public_snet = object({
        workload  = string
        vnet_rg   = string
        vnet_name = string
        ip_range  = string

        delegation = object({
          actions            = list(string)
          service_delegation = string
        })
      })

      private_snet = object({
        is_public = optional(bool, false)
        workload  = string
        vnet_rg   = string
        vnet_name = string
        ip_range  = string

        delegation = object({
          actions            = list(string)
          service_delegation = string
        })
      })
    }), null)

    rbac = optional(list(object({
      role    = string
      members = list(string)
    })), null)
  }))
}

variable "synapse" {
  type = list(object({
    admin_user          = string
    subresources        = list(string)
    workload            = optional(string, "")
    tags                = optional(map(string), null)
    aad_admin_object_id = optional(string, null)

    rbac = optional(list(object({
      role    = string
      members = list(string)
    })), null)

    sa = object({
      subresources     = list(string)
      workload         = optional(string, "")
      tags             = optional(map(string), null)
      kind             = optional(string, "StorageV2")
      tier             = optional(string, "Standard")
      redundancy       = optional(string, "GRS")
      is_nested_public = optional(bool, false)
      is_hns           = optional(bool, false)

      soft_delete_config = optional(object({
        container = optional(number, null)
        blob      = optional(number, null)
      }), null)

      networking = optional(object({
        allow_ips   = optional(list(string), null)
        allow_snets = optional(list(string), null)
      }), null)

      rbac = optional(list(object({
        role    = string
        members = list(string)
      })), null)

      lifecycle = optional(list(object({
        name                                          = string
        blob_types                                    = string
        prefix_match                                  = optional(list(string), null)
        delete_after_days_since_creation_greater_than = number
      })), null)
    })

    sa_file_sys_ace = optional(list(object({
      permissions = string
      scope       = string
      type        = string
      object_id   = optional(string, null)
    })), null)

    synapse_sql_pool = optional(object({
      workload       = optional(string, "")
      tags           = optional(map(string), null)
      sku            = string
      create_mode    = optional(string, "Default")
      collation      = optional(string, null)
      data_encrypt   = optional(bool, false)
      is_geo_backup  = optional(bool, false)
      recovery_db_id = optional(string, null)
      restore = optional(object({
        db_id         = string
        point_in_time = string
      }), null)
    }), null)

    synapse_role = optional(list(object({
      role    = string
      members = list(string)
    })), null)

    # mpe = optional(list(object({
    #   target_name        = string
    #   target_id          = string
    #   target_subresource = string
    # })), null)
  }))
}