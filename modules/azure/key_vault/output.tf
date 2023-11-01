output "name" {
  value = (values(azurerm_key_vault.kv)[*].name)
}

output "id" {
  value = (values(azurerm_key_vault.kv)[*].id)
}

output "uri" {
  value = (values(azurerm_key_vault.kv)[*].vault_uri)
}

output "ip" {
  value = (values(module.pe)[*].ip)
}
