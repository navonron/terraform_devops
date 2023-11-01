variable "env" { type = string }
variable "location" { type = string }
variable "tags" { type = map(string) }
variable "prj_id" { type = string }

variable "rg" {
  type = list(object({
    workload = optional(string, "")

    rbac = list(object({
      role    = string
      members = list(string)
    }))
  }))
}
