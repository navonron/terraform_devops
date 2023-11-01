output "name" {
  value = (values(azurerm_subnet.snet)[*].name)
}

output "id" {
  value = (values(azurerm_subnet.snet)[*].id)
}
