module "name" {
  count    = length(var.kv_secret)
  source   = "../../general/name_conv"
  env      = var.env
  prj_id   = var.prj_id
  workload = var.kv_secret[count.index].workload
  usage    = var.kv_secret[count.index].usage
  type     = "kv_secret"
}

resource "azurerm_key_vault_secret" "secret" {
  count           = length(var.kv_secret)
  name            = module.name[count.index].name
  value           = var.kv_secret[count.index].value
  content_type    = var.kv_secret[count.index].content_type
  not_before_date = var.kv_secret[count.index].activation_date
  expiration_date = var.kv_secret[count.index].expiration_date
  key_vault_id    = var.kv_secret[count.index].kv_id
}
