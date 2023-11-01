variable "env" { type = string }
variable "location" { type = string }
variable "prj_id" { type = string }
variable "rg" { type = string }
variable "asp_id" { type = string }
variable "vnet_integration_snet_id" { type = string }
variable "pe_snet_id" { type = string }

variable "linux_web_app" {
  type = list(object({
    workload      = string
    app_settings  = optional(map(string), null)
    is_https_only = optional(bool, false)
    is_public     = optional(bool, true)
    stack         = string
    version       = optional(string, null)

    docker_config = optional(object({
      image        = string
      registry_url = string
      username     = string
      password     = string
    }), null)

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
