variable "env" { type = string }
variable "prj_id" { type = string }
variable "location" { type = string }
variable "rg" { type = string }
variable "pe_snet_id" { type = string }

variable "sa" {
  type = list(object({
    subresources     = list(string)
    workload         = optional(string, "")
    tags             = optional(map(string), null)
    kind             = optional(string, "StorageV2")
    tier             = optional(string, "Standard")
    redundancy       = optional(string, "GRS")
    is_nested_public = optional(bool, false)
    is_hns           = optional(bool, false)

    soft_delete_config = optional(object({
      container = optional(number, null)
      blob      = optional(number, null)
    }), null)

    networking = optional(object({
      allow_ips   = optional(list(string), null)
      allow_snets = optional(list(string), null)
    }), null)

    rbac = optional(list(object({
      role    = string
      members = list(string)
    })), null)

    lifecycle = optional(list(object({
      name                                          = string
      blob_types                                    = string
      prefix_match                                  = optional(list(string), null)
      delete_after_days_since_creation_greater_than = number
    })), null)
  }))

  validation {
    condition = alltrue([for sa in var.sa :
      contains(["BlobStorage", "BlockBlobStorage", "FileStorage", "Storage", "StorageV2"],
    sa.kind)])
    error_message = "SA kind OPTIONS ARE - BlobStorage, BlockBlobStorage, FileStorage, Storage, StorageV2"
  }

  validation {
    condition = alltrue([for sa in var.sa :
      contains(["Standard", "Premium"],
    sa.tier)])
    error_message = "SA tier OPTIONS ARE - Standard, Premium"
  }

  validation {
    condition = alltrue([for sa in var.sa :
      contains(["GRS", "RAGRS", "GZRS", "RAGZRS"],
    sa.redundancy)])
    error_message = "SA redundancy OPTIONS ARE - GRS, RAGRS, GZRS, RAGZRS"
  }
}
