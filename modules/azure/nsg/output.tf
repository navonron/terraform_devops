output "name" {
  value = (values(azurerm_network_security_group.nsg)[*].name)
}

output "id" {
  value = (values(azurerm_network_security_group.nsg)[*].id)
}
