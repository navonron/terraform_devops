locals {
  rules = flatten([
    for nsg_key, nsg in var.nsg : [
      for rule_key, rule in nsg.rules : {
        nsg_key             = nsg_key
        rule_key            = rule_key
        name                = rule.name
        desc                = rule.desc
        access              = rule.access
        direction           = rule.direction
        priority            = rule.priority
        protocol            = rule.protocol
        src_port_range      = rule.src_port_range
        dest_port_range     = rule.dest_port_range
        src_address_prefix  = rule.src_address_prefix
        dest_address_prefix = rule.dest_address_prefix
      }
    ] if nsg.rules != []
  ])

  associate_snet = flatten([
    for nsg_key, nsg in var.nsg : [
      for snet_key, snet in nsg.snet_ids : {
        nsg_key  = nsg_key
        snet_key = snet_key
        snet     = snet
      }
    ] if nsg.snet_ids != []
  ])
}
