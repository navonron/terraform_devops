resource "azurerm_role_assignment" "rbac" {
  for_each             = { for idx, rbac in local.rbac : "${rbac.rbac_key}.${rbac.member_key}" => rbac }
  scope                = each.value.scope
  role_definition_name = each.value.role
  principal_id         = each.value.member
}
