locals {
  rbac = flatten([
    for svc_key, svc in var.adf : [
      for rbac_key, rbac in svc.rbac : {
        svc_key  = svc_key
        rbac_key = rbac_key
        role     = rbac.role
        members  = rbac.members
      }
    ] if svc.rbac != null
  ])

  global_params = flatten([
    for adf_key, adf in var.adf : [
      for parm_key, parm in adf.global_params : {
        adf_key  = adf_key
        parm_key = parm_key
        name     = parm.name
        type     = parm.type
        value    = parm.value
      }
    ] if adf.global_params != null
  ])
}
