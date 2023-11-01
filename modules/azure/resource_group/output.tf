output "name" {
  value = (values(azurerm_resource_group.rg)[*].name)
}

output "id" {
  value = (values(azurerm_resource_group.rg)[*].id)
}
