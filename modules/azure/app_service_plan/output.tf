output "name" {
  value = (values(azurerm_service_plan.asp)[*].name)
}

output "id" {
  value = (values(azurerm_service_plan.asp)[*].id)
}
