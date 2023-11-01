module "name" {
  count    = length(var.kv_key)
  source   = "../../general/name_conv"
  env      = var.env
  prj_id   = var.prj_id
  workload = var.kv_key[count.index].workload
  usage    = var.kv_key[count.index].usage
  type     = "kv_key"
}

resource "azurerm_key_vault_key" "key" {
  count           = length(var.kv_key)
  name            = module.name[count.index].name
  key_vault_id    = var.kv_key[count.index].kv_id
  key_type        = var.kv_key[count.index].type
  key_size        = strcontains(var.kv_key[count.index].type, "RSA") == true ? var.kv_key[count.index].size : null
  curve           = strcontains(var.kv_key[count.index].type, "EC") == true ? var.kv_key[count.index].curve : null
  key_opts        = var.kv_key[count.index].opts
  expiration_date = var.kv_key[count.index].expiry_date

  dynamic "rotation_policy" {
    for_each = var.kv_key[count.index].rotation != null ? [1] : []
    content {
      expire_after         = var.kv_key[count.index].rotation.expire_after
      notify_before_expiry = var.kv_key[count.index].rotation.notify_before_expiry

      dynamic "automatic" {
        for_each = var.kv_key[count.index].rotation.auto_rotate_after != null || var.kv_key[count.index].rotation.auto_rotate_before != null ? [1] : []
        content {
          time_after_creation = var.kv_key[count.index].rotation.auto_rotate_after
          time_before_expiry  = var.kv_key[count.index].rotation.auto_rotate_before
        }
      }
    }
  }
}
