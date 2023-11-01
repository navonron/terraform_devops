variable "env" { type = string }
variable "prj_id" { type = string }

variable "kv_secret" {
  type = list(object({
    kv_id           = string
    workload        = optional(string, "")
    usage           = string
    value           = string
    content_type    = optional(string, "")
    activation_date = optional(string, null)
    expiration_date = optional(string, null)
  }))
  sensitive = true
}
