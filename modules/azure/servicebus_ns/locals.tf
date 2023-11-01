locals {
  rbac = flatten([
    for svc_key, svc in var.servicebus_ns : [
      for rbac_key, rbac in svc.rbac : {
        svc_key  = svc_key
        rbac_key = rbac_key
        role     = rbac.role
        members  = rbac.members
      }
    ] if svc.rbac != null
  ])

  queues = flatten([
    for ns_key, ns in var.servicebus_ns : [
      for queue_key, queue in ns.queues : {
        ns_key          = ns_key
        queue_key       = queue_key
        name            = queue.name
        is_partitioning = queue.is_partitioning
      }
    ] if ns.queues != null
  ])

  topics = flatten([
    for ns_key, ns in var.servicebus_ns : [
      for topic_key, topic in ns.topics : {
        ns_key          = ns_key
        topic_key       = topic_key
        name            = topic.name
        is_partitioning = topic.is_partitioning
        subscriptions   = topic.subscriptions
      }
    ] if ns.topics != null
  ])

  subscriptions = flatten([
    for ns_key, ns in var.servicebus_ns : [
      for topic_key, topic in ns.topics : [
        for sub_key, sub in topic.subscriptions : {
          ns_key             = ns_key
          topic_key          = topic_key
          sub_key            = sub_key
          name               = sub.name
          max_delivery_count = sub.max_delivery_count
        }
      ] if topic.subscriptions != null
    ] if ns.topics != null
  ])
}
