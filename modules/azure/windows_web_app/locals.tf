locals {
  rules = flatten([
    for app_key, app in var.windows_web_app : [
      for rule_key, rule in app.rules : {
        app_key     = app_key
        rule_key    = rule_key
        action      = rule.action
        priority    = rule.priority
        allow_ip    = rule.allow_ip
        allow_snet  = rule.allow_snet
        service_tag = rule.service_tag
      }
    ] if app.rules != null
  ])

  rbac = flatten([
    for svc_key, svc in var.windows_web_app : [
      for rbac_key, rbac in svc.rbac : {
        svc_key  = svc_key
        rbac_key = rbac_key
        role     = rbac.role
        members  = rbac.members
      }
    ] if svc.rbac != null
  ])
}
