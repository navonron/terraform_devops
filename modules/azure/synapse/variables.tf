variable "env" { type = string }
variable "prj_id" { type = string }
variable "location" { type = string }
variable "rg" { type = string }
variable "pe_snet_id" { type = string }
variable "tenant_id" { type = string }
variable "kv_id" { type = string }

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

    mpe = optional(list(object({
      target_name        = string
      target_id          = string
      target_subresource = string
    })), null)
  }))
}
