output "id" {
  value = azurerm_private_endpoint.pe.id
}

output "name" {
  value = azurerm_private_endpoint.pe.name
}

output "ip" {
  value = azurerm_private_endpoint.pe.private_service_connection.0.private_ip_address
}

output "fqdn" {
  value = azurerm_private_endpoint.pe.custom_dns_configs.0.fqdn
}
