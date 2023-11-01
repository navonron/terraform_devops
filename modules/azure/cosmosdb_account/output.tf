output "name" {
  value = (values(azurerm_cosmosdb_account.cosmosdb)[*].name)
}

output "id" {
  value = (values(azurerm_cosmosdb_account.cosmosdb)[*].id)
}

output "ip" {
  value = (values(module.pe)[*].ip)
}