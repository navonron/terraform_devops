locals {
  rules = flatten([
    for func_key, func in var.windows_func : [
      for rule_key, rule in func.rules : {
        func_key    = func_key
        rule_key    = rule_key
        action      = rule.action
        priority    = rule.priority
        allow_ip    = rule.allow_ip
        allow_snet  = rule.allow_snet
        service_tag = rule.service_tag
      }
    ] if func.rules != null
  ])

  rbac = flatten([
    for svc_key, svc in var.windows_func : [
      for rbac_key, rbac in svc.rbac : {
        svc_key  = svc_key
        rbac_key = rbac_key
        role     = rbac.role
        members  = rbac.members
      }
    ] if svc.rbac != null
  ])

  slots = flatten([
    for func_key, func in var.windows_func : [
      for slot_key, slot in func.slots : {
        func_key = func_key
        slot_key = slot_key
        slots    = func.slots
      }
    ] if func.slots != null
  ])
}
