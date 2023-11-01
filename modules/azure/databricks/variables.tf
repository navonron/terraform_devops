variable "env" { type = string }
variable "prj_id" { type = string }
variable "location" { type = string }
variable "rg" { type = string }
variable "pe_snet_id" { type = string }

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
