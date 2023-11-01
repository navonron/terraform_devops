output "name" {
  value = (values(azurerm_servicebus_namespace.servicebus_ns)[*].name)
}

output "id" {
  value = (values(azurerm_servicebus_namespace.servicebus_ns)[*].id)
}

output "ip" {
  value = (values(module.pe)[*].ip)
}