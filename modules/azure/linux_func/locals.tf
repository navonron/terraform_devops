locals {
  rules = flatten([
    for func_key, func in var.linux_func : [
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
    for func_key, func in var.linux_func : [
      for role_key, role in func.rbac : {
        func_key      = func_key
        role_key      = role_key
        role          = role.role
        principal_ids = role.principal_ids
      }
    ] if func.rbac != null
  ])
}