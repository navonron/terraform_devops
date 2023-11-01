output "name" {
  value = (values(azurerm_data_factory.adf)[*].name)
}

output "id" {
  value = (values(azurerm_data_factory.adf)[*].id)
}

output "principal_id" {
  value = (values(azurerm_data_factory.adf)[*].identity.0.principal_id)
}

output "ip" {
  value = (values(module.pe)[*].ip)
}