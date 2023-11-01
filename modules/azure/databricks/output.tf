output "name" {
  value = (values(azurerm_databricks_workspace.databricks)[*].name)
}

output "id" {
  value = (values(azurerm_databricks_workspace.databricks)[*].id)
}

output "ip" {
  value = (values(module.pe)[*].ip)
}

output "fqdn" {
  value = (values(module.pe)[*].fqdn)
}