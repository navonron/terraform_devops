output "name" {
  value     = azurerm_key_vault_key.key.*.name
  sensitive = true
}

output "id" {
  value     = azurerm_key_vault_key.key.*.id
  sensitive = true
}

output "versionless_id" {
  value     = azurerm_key_vault_key.key.*.versionless_id
  sensitive = true
}
