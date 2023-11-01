locals {
  resources_ips = concat(
    module.windows_web_app.ip[*],
    module.windows_func.ip[*],
    # module.eventhub_ns.ip[*],
    # module.kv.name[*],
    module.sql.ip[*],
    module.servicebus_ns.ip[*],
    module.adf.ip[*],
    module.databricks.ip[*],
  )

  resources_names = concat(
    module.windows_web_app.name[*],
    module.windows_func.name[*],
    # module.eventhub_ns.name[*],
    # module.kv.ip[*],
    module.sql.name[*],
    module.servicebus_ns.name[*],
    module.adf.name[*],
    module.databricks.name[*],
  )

  subresources = flatten([
    for svc_key, svc in var.sa : [
      for sub_key, sub in svc.subresources : {
        svc_key     = svc_key
        sub_key     = sub_key
        subresource = sub
        ip          = module.sa.ip[sub_key]
      }
    ]
  ])
}
