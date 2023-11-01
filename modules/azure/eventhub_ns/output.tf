output "name" {
  value = (values(azurerm_eventhub_namespace.eventhub_ns)[*].name)
}

output "id" {
  value = (values(azurerm_eventhub_namespace.eventhub_ns)[*].id)
}

output "ip" {
  value = (values(module.pe)[*].ip)
}