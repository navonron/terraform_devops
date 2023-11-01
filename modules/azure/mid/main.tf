module "name" {
  source   = "../../general/name_conv"
  env      = var.env
  prj_id   = var.prj_id
  workload = var.workload
  type     = "mid"
}


resource "azurerm_user_assigned_identity" "mid" {
  location            = var.location
  name                = module.name.name
  resource_group_name = var.rg
}
