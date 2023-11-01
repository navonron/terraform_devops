variable "env" { type = string }
variable "prj_id" { type = string }
variable "location" { type = string }
variable "rg" { type = string }

variable "nsg" {
  type = list(object({
    workload = string
    tags     = optional(map(string), null)
    snet_ids = optional(list(string), [])
    rules = optional(list(object({
      name                       = string
      priority                   = number
      description                = optional(string, null)
      access                     = optional(string, "Allow")
      direction                  = optional(string, "Inbound")
      protocol                   = optional(string, "*")
      source_port_range          = optional(string, "*")
      destination_port_range     = optional(string, "*")
      source_address_prefix      = optional(string, "*")
      destination_address_prefix = optional(string, "*")
    })), [])
  }))
}
