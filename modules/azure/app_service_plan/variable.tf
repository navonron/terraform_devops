variable "env" { type = string }
variable "location" { type = string }
variable "prj_id" { type = string }
variable "rg" { type = string }

variable "asp" {
  type = list(object({
    os          = string
    sku         = string
    workload    = optional(string, "")
    tags        = optional(map(string), null)
    is_zrs      = optional(bool, false)
    max_elastic = optional(number, null)
    instances   = optional(number, 1)
  }))

  validation {
    condition = alltrue([for asp in var.asp :
      contains(["Windows", "Linux", "WindowsContainer"],
    asp.os)])
    error_message = "ASP os OPTIONS ARE - Windows, Linux, WindowsContainer"
  }

  validation {
    condition = alltrue([for asp in var.asp :
      contains(["B1", "B2", "B3", "D1", "F1",
        "I1", "I2", "I3", "I1v2", "I2v2", "I3v2", "I4v2", "I5v2", "I6v2",
        "P1v2", "P2v2", "P3v2", "P0v3", "P1v3", "P2v3", "P3v3",
        "P1mv3", "P2mv3", "P3mv3", "P4mv3", "P5mv3",
        "S1", "S2", "S3", "SHARED",
        "EP1", "EP2", "EP3", "WS1", "WS2", "WS3", "Y1"],
    asp.sku)])
    error_message = "ASP sku OPTIONS ARE - B1, B2, B3, D1, F1, I1, I2, I3, I1v2, I2v2, I3v2, I4v2, I5v2, I6v2, P1v2, P2v2, P3v2, P0v3, P1v3, P2v3, P3v3, P1mv3, P2mv3, P3mv3, P4mv3, P5mv3, S1, S2, S3, SHARED, EP1, EP2, EP3, WS1, WS2, WS3, Y1"
  }
}
