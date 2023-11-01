output "name" {
  value = (values(azurerm_mssql_server.sql_server)[*].name)
}

output "id" {
  value = (values(azurerm_mssql_server.sql_server)[*].id)
}

output "ip" {
  value = (values(module.pe)[*].ip)
}

output "db_name" {
  value = (values(azurerm_mssql_database.db)[*].name)
}

output "db_id" {
  value = (values(azurerm_mssql_database.db)[*].id)
}
