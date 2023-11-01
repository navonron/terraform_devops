locals {
  subscriptions = flatten([
    for topic_key, topic in var.eventgrid_sys_topic : [
      for sub_key, sub in topic.subscriptions : {
        topic_key                   = topic_key
        sub_key                     = sub_key
        includ_events               = sub.includ_events
        is_array_advanced_filtering = sub.is_array_advanced_filtering
        queue_ep                    = sub.queue_ep
        webhook_ep                  = sub.webhook_ep
        max_delivery_attempt        = sub.max_delivery_attempt
        event_time_to_live          = sub.event_time_to_live
        advanced_filter             = sub.advanced_filter
        subject_filter              = sub.subject_filter
      }
    ] if topic.subscriptions != null
  ])
}
