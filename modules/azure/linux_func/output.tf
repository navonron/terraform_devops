output "name" {
  value = (values(azurerm_linux_function_app.linux_func)[*].name)
}

output "id" {
  value = (values(azurerm_linux_function_app.linux_func)[*].id)
}

output "principal_id" {
  value = (values(azurerm_linux_function_app.linux_func)[*].identity.0.principal_id)
}

output "ip" {
  value = (values(module.pe)[*].ip)
}

output "sa_name" {
  value = (values(module.sa)[*].name)
}

output "sa_ip" {
  value = (values(module.sa)[*].ip)
}
