output "name" {
  value = (values(azurerm_synapse_workspace.synapse)[*].name)
}

output "id" {
  value = (values(azurerm_synapse_workspace.synapse)[*].id)
}

output "ip" {
  value = (values(module.pe)[*].ip)
}

output "sa_name" {
  value = module.sa[0].name[*]
}

output "sa_ip" {
  value = module.sa[0].ip[*]
}
