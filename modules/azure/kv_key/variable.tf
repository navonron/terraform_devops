variable "env" { type = string }
variable "prj_id" { type = string }

variable "kv_key" {
  type = list(object({
    kv_id       = string
    usage       = string
    type        = string
    opts        = list(string)
    workload    = optional(string, "")
    size        = optional(number, 2048)
    curve       = optional(string, "P-256")
    expiry_date = optional(string, null)

    rotation = optional(object({
      expire_after         = optional(string, null)
      notify_before_expiry = optional(string, null)
      auto_rotate_after    = optional(string, null)
      auto_rotate_before   = optional(string, null)
    }))

  }))
  sensitive = true

  validation {
    condition = alltrue([for key in var.kv_key :
      contains(["EC", "EC-HSM", "RSA", "RSA-HSM"],
    key.type)])
    error_message = "KV KEY type OPTIONS ARE - EC, EC-HSM, RSA, RSA-HSM"
  }

  validation {
    condition = alltrue([for key in var.kv_key :
      can(regex("^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}Z$", key.expiry_date)) ||
    key.expiry_date == null])
    error_message = "INVALID KV KEY expiry_date FORMAT. USE THE FOLLOWING FORMAT: (Y-m-d'T'H:M:S'Z')"
  }

  validation {
    condition = alltrue([for key in var.kv_key :
      can(regex("^P(?:\\d+Y)?(?:\\d+M)?(?:\\d+D)?(?:T(?:\\d+H)?(?:\\d+M)?(?:\\d+(?:\\.\\d+)?S)?)?$", key.rotation.expire_after)) ||
    key.rotation.expire_after == null])
    error_message = "INVALID KV KEY expire_after FORMAT. USE ISO 8601 FORMAT"
  }

  validation {
    condition = alltrue([for key in var.kv_key :
      can(regex("^P(?:\\d+Y)?(?:\\d+M)?(?:\\d+D)?(?:T(?:\\d+H)?(?:\\d+M)?(?:\\d+(?:\\.\\d+)?S)?)?$", key.rotation.notify_before_expiry)) ||
    key.rotation.notify_before_expiry == null])
    error_message = "INVALID KV KEY notify_before_expiry FORMAT. USE ISO 8601 FORMAT"
  }


  validation {
    condition = alltrue([for key in var.kv_key :
      can(regex("^P(?:\\d+Y)?(?:\\d+M)?(?:\\d+D)?(?:T(?:\\d+H)?(?:\\d+M)?(?:\\d+(?:\\.\\d+)?S)?)?$", key.rotation.auto_rotate_after)) ||
    key.rotation.auto_rotate_after == null])
    error_message = "INVALID KV KEY auto_rotate_after FORMAT. USE ISO 8601 FORMAT"
  }

  validation {
    condition = alltrue([for key in var.kv_key :
      can(regex("^P(?:\\d+Y)?(?:\\d+M)?(?:\\d+D)?(?:T(?:\\d+H)?(?:\\d+M)?(?:\\d+(?:\\.\\d+)?S)?)?$", key.rotation.auto_rotate_before)) ||
    key.rotation.auto_rotate_before == null])
    error_message = "INVALID KV KEY auto_rotate_before FORMAT. USE ISO 8601 FORMAT"
  }
}
