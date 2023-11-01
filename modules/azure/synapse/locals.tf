locals {
  rbac = flatten([
    for svc_key, svc in var.synapse : [
      for rbac_key, rbac in svc.rbac : {
        svc_key  = svc_key
        rbac_key = rbac_key
        role     = rbac.role
        members  = rbac.members
      }
    ] if svc.rbac != null
  ])

  subresources = flatten([
    for svc_key, svc in var.synapse : [
      for sub_key, sub in svc.subresources : {
        svc_key     = svc_key
        sub_key     = sub_key
        workload    = svc.workload
        subresource = sub
      }
    ]
  ])

  synapse_role = flatten([
    for synapse_key, synapse in var.synapse : [
      for role_key, role in synapse.synapse_role : [
        for member_key, member in role.members : {
          synapse_key = synapse_key
          role_key    = role_key
          member_key  = member_key
          role        = role.role
          member      = member
        }
      ]
    ] if synapse.synapse_role != null
  ])

  mpe = flatten([
    for synapse_key, synapse in var.synapse : [
      for mpe_key, mpe in synapse.mpe : {
        synapse_key        = synapse_key
        mpe_key            = mpe_key
        target_name        = mpe.target_name
        target_id          = mpe.target_id
        target_subresource = mpe.target_subresource
      }
    ] if synapse.mpe != null
  ])
}
