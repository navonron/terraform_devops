output "name" {
  value = (values(azurerm_windows_web_app.web_app)[*].name)
}

output "id" {
  value = (values(azurerm_windows_web_app.web_app)[*].id)
}

output "principal_id" {
  value = (values(azurerm_windows_web_app.web_app)[*].identity.0.principal_id)
}

output "ip" {
  value = (values(module.pe)[*].ip)
}

output "fqdn" {
  value = (values(module.pe)[*].fqdn)
}