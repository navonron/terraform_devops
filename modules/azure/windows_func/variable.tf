variable "env" { type = string }
variable "location" { type = string }
variable "prj_id" { type = string }
variable "rg" { type = string }
variable "asp_id" { type = string }
variable "vnet_integration_snet_id" { type = string }
variable "pe_snet_id" { type = string }
variable "sa_name" { type = string }
variable "sa_primary_access_key" { type = string }

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
