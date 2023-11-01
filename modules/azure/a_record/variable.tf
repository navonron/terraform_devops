variable "res_name" { type = string }
variable "ip" { type = string }
variable "zone_name" { type = string }
variable "zone_rg" { type = string }

variable "ttl" {
  description = "[IF YES | REQUIRED] do you want to register new A record in an Azure private DNS zone?"
  type        = number
  default     = 3600
}
