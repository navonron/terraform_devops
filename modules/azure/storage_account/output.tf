output "name" {
  value = (values(azurerm_storage_account.sa)[*].name)
}

output "id" {
  value = (values(azurerm_storage_account.sa)[*].id)
}

output "primary_access_key" {
  value = (values(azurerm_storage_account.sa)[*].primary_access_key)
}

output "ip" {
  value = (values(module.pe)[*].ip)
}

output "fqdn" {
  value = (values(module.pe)[*].fqdn)
}

output "pe_name" {
  value = (values(module.pe)[*].name)
}
