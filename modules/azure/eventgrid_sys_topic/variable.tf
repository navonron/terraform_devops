variable "env" { type = string }
variable "prj_id" { type = string }
variable "location" { type = string }
variable "rg" { type = string }
variable "sa_id" { type = string }

variable "eventgrid_sys_topic" {
  type = list(object({
    type     = string
    workload = optional(string, "")
    tags     = optional(map(string), null)

    subscriptions = optional(list(object({
      name                        = string
      includ_events               = optional(list(string), null)
      is_array_advanced_filtering = optional(bool, false)
      max_delivery_attempt        = optional(number, 1)
      event_time_to_live          = optional(number, 1440)

      queue_ep = optional(object({
        name             = string
        sa_id            = string
        msg_time_to_live = optional(number, 604800)
      }), null)

      webhook_ep = optional(object({
        url                     = string
        max_events_per_batch    = optional(number, 1)
        preferred_batch_size_kb = optional(number, 64)
      }), null)

      advanced_filter = optional(object({
        string_ends_with = optional(object({
          key    = string
          values = list(string)
        }), null)

        string_begins_with = optional(object({
          key    = string
          values = list(string)
        }), null)

        string_not_in = optional(object({
          key    = string
          values = list(string)
        }), null)

        number_greater_than = optional(object({
          key   = string
          value = string
        }), null)

        string_in = optional(object({
          key    = string
          values = list(string)
        }), null)
      }), null)

      subject_filter = optional(object({
        begins_with = optional(string, null)
        ends_with   = optional(string, null)
      }), null)
    })), null)
  }))
}
