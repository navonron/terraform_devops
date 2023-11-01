module "name" {
  source   = "../../general/name_conv"
  for_each = { for idx, sa in var.sa : idx => sa }
  env      = var.env
  prj_id   = var.prj_id
  workload = each.value.workload
  type     = "sa"
}

resource "azurerm_storage_account" "sa" {
  for_each                        = { for idx, sa in var.sa : idx => sa }
  name                            = module.name[each.key].name
  resource_group_name             = var.rg
  location                        = var.location
  tags                            = each.value.tags
  account_kind                    = each.value.kind
  account_tier                    = each.value.tier
  account_replication_type        = each.value.redundancy
  allow_nested_items_to_be_public = each.value.is_nested_public
  is_hns_enabled                  = each.value.is_hns
  min_tls_version                 = "TLS1_2"
  enable_https_traffic_only       = true
  public_network_access_enabled   = false

  dynamic "blob_properties" {
    for_each = each.value.soft_delete_config != null ? [1] : []

    content {
      dynamic "delete_retention_policy" {
        for_each = each.value.soft_delete_config.blob != null ? [1] : []
        content {
          days = each.value.soft_delete_config.blob
        }
      }

      dynamic "container_delete_retention_policy" {
        for_each = each.value.soft_delete_config.container != null ? [1] : []
        content {
          days = each.value.soft_delete_config.container
        }
      }
    }
  }

  dynamic "network_rules" {
    for_each = each.value.networking != null ? [1] : []
    content {
      default_action             = "Deny"
      bypass                     = ["AzureServices"]
      ip_rules                   = each.value.networking.allow_ips
      virtual_network_subnet_ids = each.value.networking.allow_snets
    }
  }
}

module "rbac" {
  source   = "../rbac"
  for_each = { for idx, rbac in local.rbac : "${rbac.svc_key}.${rbac.rbac_key}" => rbac }
  rbac = [{
    scope   = azurerm_storage_account.sa[each.value.svc_key].id
    role    = each.value.role
    members = each.value.members
  }]
}

module "pe" {
  source       = "../private_endpoint"
  for_each     = { for idx, sub in local.subresources : "${sub.svc_key}.${sub.sub_key}" => sub }
  rg           = var.rg
  location     = var.location
  snet_id      = var.pe_snet_id
  res_name     = "${module.name[each.value.svc_key].name}.${each.value.subresource}"
  res_type     = "storage_account${each.value.workload == null ? "_${each.value.workload}" : ""}"
  res_id       = azurerm_storage_account.sa[each.value.svc_key].id
  subresources = [each.value.subresource]
}

resource "azurerm_storage_management_policy" "management_policy" {
  for_each           = { for idx, sa in var.sa : idx => sa if sa.lifecycle != null }
  storage_account_id = azurerm_storage_account.sa[each.key].id

  dynamic "rule" {
    for_each = { for idx, rule in local.lifecycle : "${rule.sa_key}.${rule.rule_key}" => rule }
    content {
      name    = rule.value.name
      enabled = true

      filters {
        blob_types   = [rule.value.blob_types]
        prefix_match = rule.value.prefix_match
      }

      actions {
        base_blob {
          delete_after_days_since_creation_greater_than = rule.value.delete_after_days_since_creation_greater_than
        }
      }
    }
  }
}
