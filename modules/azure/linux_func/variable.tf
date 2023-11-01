variable "env" { type = string }
variable "location" { type = string }
variable "prj_id" { type = string }
variable "rg" { type = string }
variable "asp_id" { type = string }
variable "vnet_integration_snet_id" { type = string }
variable "pe_snet_id" { type = string }

variable "sa" {
  type = list(object({
    workload              = optional(string, "")
    tags                  = optional(map(string), null)
    kind                  = optional(string, "StorageV2")
    tier                  = optional(string, "Standard")
    replication           = optional(string, "LRS")
    is_https_only         = optional(bool, true)
    is_nested_public      = optional(bool, true)
    is_hns                = optional(bool, true)
    container_soft_delete = optional(number, null)
    blob_soft_delete      = optional(number, null)
    subresources          = list(string)

    net_rule = optional(object({
      action      = optional(string, "Deny")
      bypass      = optional(list(string), null)
      allow_ips   = optional(list(string), null)
      allow_snets = optional(list(string), null)
    }), null)

    rbac = optional(list(object({
      role          = string
      principal_ids = list(string)
    })), null)

    managed_rules = optional(list(object({
      name                                          = string
      blob_types                                    = string
      prefix_match                                  = optional(list(string), null)
      delete_after_days_since_creation_greater_than = number
    })), [])
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
      contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"],
    sa.replication)])
    error_message = "SA replication OPTIONS ARE - LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS"
  }

  validation {
    condition = alltrue([for sa in var.sa :
      contains(["Deny", "Allow"],
    sa.net_rule.action)])
    error_message = "SA net_rule.action OPTIONS ARE - Deny, Allow"
  }
}

variable "linux_func" {
  type = list(object({
    workload      = string
    app_settings  = optional(map(string), null)
    is_https_only = optional(bool, true)
    is_public     = optional(bool, true)

    stack = object({
      dotnet_version          = optional(string, null)
      java_version            = optional(string, null)
      node_version            = optional(string, null)
      python_version          = optional(string, null)
      powershell_core_version = optional(string, null)
      docker = optional(object({
        registry_url      = optional(string, null)
        image_name        = optional(string, null)
        image_tag         = optional(string, null)
        registry_username = optional(string, null)
      }), null)
    })

    rules = optional(list(object({
      action      = optional(string, "Deny")
      priority    = optional(number, null)
      allow_ip    = optional(string, null)
      allow_snet  = optional(string, null)
      service_tag = optional(string, null)
    })), null)

    rbac = optional(list(object({
      role          = string
      principal_ids = list(string)
    })), null)
  }))
}
