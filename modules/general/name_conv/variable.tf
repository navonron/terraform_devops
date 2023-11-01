variable "type" {
  description = "[REQUIRED] type of the resource in lower case, for example: 'resource_group' or 'subnet'."
  type        = string
  validation {
    condition = contains([
      "rg", "asp", "app", "func", "sa", "event_hub_ns",
      "sql_server", "sql_db", "servicebus_ns", "kv", "kv_secret", "kv_key", "adf",
      "eventgrid_sys_topic", "cosmosdb", "databricks", "snet", "nsg", "synapse", "synapse_link_hub", "synapse_sql_pool",
      "mid"
    ], var.type)
    error_message = "The type value was not recognized as a supported resource type, either correct the type or add support for this resource in the module."
  }
}

variable "env" { type = string }
variable "prj_id" { type = string }
variable "workload" { type = string }

variable "asp_os" {
  type = string
  validation {
    condition     = contains(["Windows", "Linux"], var.asp_os)
    error_message = "asp_os must be one of the following: Windows or Linux"
  }
  default = "Windows"
}

variable "usage" {
  type    = string
  default = ""
}

variable "cosmos_api" {
  type    = string
  default = ""
}

variable "is_public" {
  type    = bool
  default = true
}
