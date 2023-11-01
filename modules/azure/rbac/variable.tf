variable "rbac" {
  description = "assigns a given principal (user/group/app) to a given role"

  type = list(object({
    scope   = string
    role    = string
    members = list(string)
  }))
}
