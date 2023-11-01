variable "env" { type = string }
variable "prj_id" { type = string }
variable "location" { type = string }
variable "rg" { type = string }
variable "pe_snet_id" { type = string }
variable "tenant_id" { type = string }
variable "kv_id" { type = string }

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
