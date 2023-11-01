variable "env" { type = string }
variable "prj_id" { type = string }
variable "location" { type = string }
variable "rg" { type = string }
variable "pe_snet_id" { type = string }

variable "eventhub_ns" {
  type = list(object({
    sku             = string
    workload        = optional(string, "")
    tags            = optional(map(string), null)
    capacity        = optional(number, null)
    is_auto_inflate = optional(bool, false)
    is_zrs          = optional(bool, false)
    is_local_auth   = optional(bool, true)
    max_throughput  = optional(number, null)

    networking = optional(object({
      allow_snets            = optional(list(string), [])
      ips_mask               = optional(list(string), [])
      ips_mask_action        = optional(string, "Deny")
    }), null)

    acess_policies = optional(list(object({
      name      = string
      is_listen = optional(bool, false)
      is_send   = optional(bool, false)
      is_manage = optional(bool, false)
    })), null)

    instances = optional(list(object({
      name            = string
      partition_count = optional(number, 1)
      msg_retention   = optional(number, 1)
      auth_rule = optional(object({
        name      = string
        is_listen = optional(bool, false)
        is_send   = optional(bool, false)
        is_manage = optional(bool, false)
      }), null)
    })), null)

    rbac = optional(list(object({
      role    = string
      members = list(string)
    })), null)
  }))
}
