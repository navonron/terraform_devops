output "name" {
  value = (values(azurerm_linux_web_app.linux_web_app)[*].name)
}

output "id" {
  value = (values(azurerm_linux_web_app.linux_web_app)[*].id)
}

output "principal_id" {
  value = (values(azurerm_linux_web_app.linux_web_app)[*].identity.0.principal_id)
}

output "ip" {
  value = (values(module.pe)[*].ip)
}
