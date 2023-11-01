variable "env" { type = string }
variable "prj_id" { type = string }
variable "location" { type = string }
variable "rg" { type = string }
variable "pe_snet_id" { type = string }
variable "tenant_id" { type = string }

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
