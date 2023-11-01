variable "env" { type = string }
variable "prj_id" { type = string }
variable "location" { type = string }
variable "rg" { type = string }
variable "pe_snet_id" { type = string }
variable "kv_id" { type = string }

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
