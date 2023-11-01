variable "env" { type = string }
variable "prj_id" { type = string }
variable "location" { type = string }
variable "rg" { type = string }
variable "pe_snet_id" { type = string }
variable "link_kv_id" { type = string }

variable "adf" {
  type = list(object({
    workload        = optional(string, "")
    tags            = optional(map(string), null)
    is_managed_vnet = optional(bool, true)

    global_params = optional(list(object({
      name  = string
      type  = string
      value = string
    })), null)

    rbac = optional(list(object({
      role    = string
      members = list(string)
    })), null)
  }))
}
