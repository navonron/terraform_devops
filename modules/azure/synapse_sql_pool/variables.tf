variable "env" { type = string }
variable "prj_id" { type = string }
variable "synapse_id" { type = string }

variable "synapse_sql_pool" {
  type = list(object({
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
  }))
}
