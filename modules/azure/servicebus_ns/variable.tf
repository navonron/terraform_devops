variable "env" { type = string }
variable "prj_id" { type = string }
variable "location" { type = string }
variable "rg" { type = string }
variable "pe_snet_id" { type = string }
variable "kv_id" { type = string }

variable "servicebus_ns" {
  type = list(object({
    sku           = string
    workload      = optional(string, "")
    tags          = optional(map(string), null)
    capacity      = optional(number, null)
    is_local_auth = optional(bool, true)
    is_zrs        = optional(bool, false)

    networking = optional(object({
      trusted_service_access = optional(bool, true)
      allow_ips              = optional(list(string), [])
      allow_snets            = optional(list(string), [])
    }), null)

    queues = optional(list(object({
      name            = string
      is_partitioning = optional(bool, false)
    })), null)

    topics = optional(list(object({
      name            = string
      is_partitioning = optional(bool, false)
      subscriptions = optional(list(object({
        name               = string
        max_delivery_count = optional(number, 2000)
      })), null)
    })), null)

    rbac = optional(list(object({
      role    = string
      members = list(string)
    })), null)
  }))
}
