variable "sa_name" { type = string }
variable "sa_id" { type = string }

variable "ace" {
  type = list(object({
    permissions = string
    scope       = string
    type        = string
    object_id   = optional(string, null)
  }))
  default = null
}
