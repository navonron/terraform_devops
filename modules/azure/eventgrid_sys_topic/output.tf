output "name" {
  value = (values(azurerm_eventgrid_system_topic.topic)[*].name)
}

output "id" {
  value = (values(azurerm_eventgrid_system_topic.topic)[*].id)
}
