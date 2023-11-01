module "name" {
  source   = "../../general/name_conv"
  for_each = { for idx, nsg in var.nsg : idx => nsg }
  env      = var.env
  prj_id   = var.prj_id
  workload = each.value.workload
  type     = "nsg"
}

resource "azurerm_network_security_group" "nsg" {
  for_each            = { for idx, nsg in var.nsg : idx => nsg }
  name                = module.name[each.key].name
  resource_group_name = var.rg
  location            = var.location
  tags                = each.value.tags

  dynamic "security_rule" {
    for_each = { for idx, rule in local.rules : "${rule.nsg_key}.${rule.rule_key}" => rule }
    content {
      name                       = each.value.name
      description                = each.value.desc
      access                     = each.value.access
      direction                  = each.value.direction
      priority                   = each.value.priority
      protocol                   = each.value.protocol
      source_port_range          = each.value.src_port_range
      destination_port_range     = each.value.dest_port_range
      source_address_prefix      = each.value.src_address_prefix
      destination_address_prefix = each.value.dest_address_prefix
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "associate_snet" {
  for_each                  = { for idx, snet in local.associate_snet : "${snet.nsg_key}.${snet.snet_key}" => snet }
  subnet_id                 = each.value.snet
  network_security_group_id = azurerm_network_security_group.nsg[each.value.nsg_key].id
}
