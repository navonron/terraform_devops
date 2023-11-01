locals {
  rbac = flatten([
    for svc_key, svc in var.eventhub_ns : [
      for rbac_key, rbac in svc.rbac : {
        svc_key  = svc_key
        rbac_key = rbac_key
        role     = rbac.role
        members  = rbac.members
      }
    ] if svc.rbac != null
  ])

  acess_policies = flatten([
    for ns_key, ns in var.eventhub_ns : [
      for policy_key, policy in ns.acess_policies : {
        ns_key     = ns_key
        policy_key = policy_key
        name       = policy.name
        is_listen  = policy.is_listen
        is_send    = policy.is_send
        is_manage  = policy.is_manage
      }
    ] if ns.acess_policies != null
  ])

  instances = flatten([
    for ns_key, ns in var.eventhub_ns : [
      for instance_key, instance in ns.instances : {
        ns_key          = ns_key
        instance_key    = instance_key
        name            = instance.name
        partition_count = instance.partition_count
        msg_retention   = instance.msg_retention
        auth_rule       = instance.auth_rule
      }
    ] if ns.instances != null
  ])
}
