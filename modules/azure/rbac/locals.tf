locals {
  rbac = flatten([
    for rbac_key, rbac in var.rbac : [
      for member_key, member in rbac.members : {
        rbac_key   = rbac_key
        member_key = member_key
        scope      = rbac.scope
        role       = rbac.role
        member     = member
      }
    ]
  ])
}
