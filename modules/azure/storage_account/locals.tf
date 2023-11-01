locals {
  rbac = flatten([
    for svc_key, svc in var.sa : [
      for rbac_key, rbac in svc.rbac : {
        svc_key  = svc_key
        rbac_key = rbac_key
        role     = rbac.role
        members  = rbac.members
      }
    ] if svc.rbac != null
  ])

  subresources = flatten([
    for svc_key, svc in var.sa : [
      for sub_key, sub in svc.subresources : {
        svc_key     = svc_key
        sub_key     = sub_key
        workload    = svc.workload
        subresource = sub
      }
    ]
  ])

  lifecycle = flatten([
    for sa_key, sa in var.sa : [
      for rule_key, rule in sa.lifecycle : {
        sa_key                                        = sa_key
        rule_key                                      = rule_key
        name                                          = rule.name
        blob_types                                    = rule.blob_types
        prefix_match                                  = rule.prefix_match
        delete_after_days_since_creation_greater_than = rule.delete_after_days_since_creation_greater_than
      }
    ] if sa.lifecycle != null
  ])
}
