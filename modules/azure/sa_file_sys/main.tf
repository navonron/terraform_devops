resource "azurerm_storage_data_lake_gen2_filesystem" "file_sys" {
  name               = "${var.sa_name}-file"
  storage_account_id = var.sa_id

  dynamic "ace" {
    for_each = var.ace != null ? [for ace in var.ace : ace] : []
    content {
      permissions = ace.value.permissions
      scope       = ace.value.scope
      type        = ace.value.type
      id          = ace.value.type == "user" || ace.value.type == "group" ? ace.value.object_id : null
    }
  }
}
