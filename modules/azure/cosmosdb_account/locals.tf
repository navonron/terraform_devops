locals {
  rbac = flatten([
    for svc_key, svc in var.cosmosdb : [
      for rbac_key, rbac in svc.rbac : {
        svc_key  = svc_key
        rbac_key = rbac_key
        role     = rbac.role
        members  = rbac.members
      }
    ] if svc.rbac != null
  ])

  subresources = flatten([
    for svc_key, svc in var.cosmosdb : [
      for sub_key, sub in svc.subresources : {
        svc_key     = svc_key
        sub_key     = sub_key
        workload    = svc.workload
        subresource = sub
      }
    ]
  ])
}

