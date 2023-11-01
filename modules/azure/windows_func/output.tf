output "name" {
  value = (values(azurerm_windows_function_app.func)[*].name)
}

output "id" {
  value = (values(azurerm_windows_function_app.func)[*].id)
}

output "principal_id" {
  value = (values(azurerm_windows_function_app.func)[*].identity.0.principal_id)
}

output "ip" {
  value = (values(module.pe)[*].ip)
}

output "fqdn" {
  value = (values(module.pe)[*].fqdn)
}
