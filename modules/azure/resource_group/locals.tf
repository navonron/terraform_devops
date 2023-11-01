locals {
  rbac = flatten([
    for svc_key, svc in var.rg : [
      for rbac_key, rbac in svc.rbac : {
        svc_key  = svc_key
        rbac_key = rbac_key
        role     = rbac.role
        members  = rbac.members
      }
    ]
  ])
}
