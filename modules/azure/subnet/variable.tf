variable "env" { type = string }
variable "prj_id" { type = string }

variable "snet" {
  type = list(object({
    is_public = optional(bool, true)
    workload  = string
    vnet_rg   = string
    vnet_name = string
    ip_range  = string

    delegation = optional(object({
      actions            = list(string)
      service_delegation = string
    }), null)
  }))
}
