variable "env" { type = string }
variable "prj_id" { type = string }
variable "tenant_id" { type = string }
variable "adf_id" { type = string }
variable "adf_principal_id" { type = string }
variable "kv_link_name" { type = string }

variable "link" {
  type = list(object({
    name  = string
    key   = string
    kv_id = string
  }))
}
