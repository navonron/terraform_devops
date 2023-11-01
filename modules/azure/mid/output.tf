output "id" {
  value = azurerm_user_assigned_identity.mid.id
}

output "client_id" {
  value = azurerm_user_assigned_identity.mid.client_id
}

output "principal_id" {
  value = azurerm_user_assigned_identity.mid.principal_id
}
