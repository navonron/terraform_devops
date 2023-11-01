module "name" {
  source   = "../../general/name_conv"
  for_each = { for idx, topic in var.eventgrid_sys_topic : idx => topic }
  env      = var.env
  prj_id   = var.prj_id
  workload = each.value.workload
  type     = "eventgrid_sys_topic"
}

resource "azurerm_eventgrid_system_topic" "topic" {
  for_each               = { for idx, topic in var.eventgrid_sys_topic : idx => topic }
  name                   = module.name[each.key].name
  resource_group_name    = var.rg
  location               = var.location
  tags                   = each.value.tags
  source_arm_resource_id = var.sa_id
  topic_type             = each.value.type
}

resource "azurerm_eventgrid_system_topic_event_subscription" "subscription" {
  for_each                             = { for idx, sub in local.subscriptions : "${sub.topic_key}.${sub.sub_key}" => sub }
  name                                 = each.value.name
  system_topic                         = azurerm_eventgrid_system_topic.topic[each.value.topic_key].name
  resource_group_name                  = var.rg
  included_event_types                 = each.value.includ_events
  advanced_filtering_on_arrays_enabled = each.value.is_array_advanced_filtering

  retry_policy {
    max_delivery_attempts = each.value.max_delivery_attempt
    event_time_to_live    = each.value.event_time_to_live
  }

  dynamic "storage_queue_endpoint" {
    for_each = each.value.queue_ep != null ? [1] : []
    content {
      queue_name                            = each.value.queue_ep.name
      storage_account_id                    = each.value.queue_ep.sa_id
      queue_message_time_to_live_in_seconds = each.value.queue_ep.msg_time_to_live
    }
  }

  dynamic "webhook_endpoint" {
    for_each = each.value.webhook_ep != null ? [1] : []
    content {
      url                               = each.value.webhook_ep.url
      max_events_per_batch              = each.value.webhook_ep.max_events_per_batch
      preferred_batch_size_in_kilobytes = each.value.webhook_ep.preferred_batch_size_kb
    }
  }

  dynamic "advanced_filter" {
    for_each = each.value.advanced_filter != null ? [1] : []
    content {

      dynamic "string_ends_with" {
        for_each = each.value.advanced_filter.string_ends_with != null ? [1] : []
        content {
          key    = each.value.advanced_filter.string_ends_with.key
          values = each.value.advanced_filter.string_ends_with.values
        }
      }

      dynamic "string_begins_with" {
        for_each = each.value.advanced_filter.string_begins_with != null ? [1] : []
        content {
          key    = each.value.advanced_filter.string_begins_with.key
          values = each.value.advanced_filter.string_begins_with.values
        }
      }

      dynamic "string_not_in" {
        for_each = each.value.advanced_filter.string_not_in != null ? [1] : []
        content {
          key    = each.value.advanced_filter.string_not_in.key
          values = each.value.advanced_filter.string_not_in.values
        }
      }

      dynamic "number_greater_than" {
        for_each = each.value.advanced_filter.number_greater_than != null ? [1] : []
        content {
          key   = each.value.advanced_filter.number_greater_than.key
          value = each.value.advanced_filter.number_greater_than.value
        }
      }

      dynamic "string_in" {
        for_each = each.value.advanced_filter.string_in != null ? [1] : []
        content {
          key    = each.value.advanced_filter.string_in.key
          values = each.value.advanced_filter.string_in.values
        }
      }
    }
  }

  dynamic "subject_filter" {
    for_each = each.value.subject_filter != null ? [1] : []
    content {
      subject_begins_with = each.value.subject_filter.begins_with
      subject_ends_with   = each.value.subject_filter.ends_with
    }
  }
}
