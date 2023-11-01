resource "azurerm_private_dns_a_record" "a_record" {
  name                = var.res_name
  zone_name           = var.zone_name
  resource_group_name = var.zone_rg
  ttl                 = var.ttl
  records             = [var.ip]
}
