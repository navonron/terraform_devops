locals {
  rules = flatten([
    for app_key, app in var.linux_web_app : [
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
    for app_key, app in var.linux_web_app : [
      for role_key, role in app.rbac : {
        app_key       = app_key
        role_key      = role_key
        role          = role.role
        principal_ids = role.principal_ids
      }
    ] if app.rbac != null
  ])
}
