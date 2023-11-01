resource "azurerm_private_endpoint" "pe" {
  name                          = "pe-${var.res_name}"
  resource_group_name           = var.rg
  location                      = var.location
  subnet_id                     = var.snet_id
  custom_network_interface_name = "nic-pe-${var.res_name}"

  tags = {
    "target-resource-type" = var.res_type
    "target-resource-name" = var.res_name
  }

  private_service_connection {
    name                           = "pesc-${var.res_name}"
    private_connection_resource_id = var.res_id
    subresource_names              = var.subresources
    is_manual_connection           = false
  }
}

# resource "null_resource" "local_host_entry" {
#   triggers = {
#     ip        = azurerm_private_endpoint.pe.private_service_connection.0.private_ip_address
#     host_name = azurerm_private_endpoint.pe.custom_dns_configs.0.fqdn
#   }

#   #   provisioner "local-exec" {
#   #     command     = "powershell.exe"
#   #     working_dir = "${path.module}/../../scripts/"
#   #     interpreter = ["powershell.exe", "-ExecutionPolicy", "Bypass", "-File", "local_host_record.ps1", "-action", "add", "-host_name", self.triggers.host_name, "-ip", self.triggers.ip]
#   #   }

#   #   provisioner "local-exec" {
#   #     when        = destroy
#   #     command     = "powershell.exe"
#   #     working_dir = "${path.module}/../../scripts/"
#   #     interpreter = ["powershell.exe", "-ExecutionPolicy", "Bypass", "-File", "local_host_record.ps1", "-action", "remove", "-host_name", self.triggers.host_name, "-ip", self.triggers.ip]
#   #   }

#   # provisioner "local-exec" {
#   #   command = "echo '${self.triggers.ip} ${self.triggers.host_name}' | sudo tee -a /etc/hosts"
#   # }

#   # provisioner "local-exec" {
#   #   when    = destroy
#   #   command = <<EOT
#   #     #!/bin/bash
#   #     host_entry="${self.triggers.ip} ${self.triggers.host_name}"
#   #     if grep -qF "$host_entry" /etc/hosts; then
#   #       sudo sed -i "/$host_entry/d" /etc/hosts
#   #     fi
#   #   EOT
#   # }


#   provisioner "local-exec" {
#     command = "echo '${var.res_name}.privatelink.ibi.westus2.azmk8s.io ${self.triggers.host_name}' | sudo tee -a /etc/hosts"
#   }

#   provisioner "local-exec" {
#     when    = destroy
#     command = <<EOT
#       #!/bin/bash
#       host_entry="${var.res_name}.privatelink.ibi.westus2.azmk8s.io ${self.triggers.host_name}"
#       if grep -qF "$host_entry" /etc/hosts; then
#         sudo sed -i "/$host_entry/d" /etc/hosts
#       fi
#     EOT
#   }
# }


# resource "null_resource" "local_host_entry" {
#   triggers = {
#     ip        = azurerm_private_endpoint.pe.private_service_connection.0.private_ip_address
#     host_name = azurerm_private_endpoint.pe.custom_dns_configs.0.fqdn
#     res_name  = var.res_name
#   }

#   provisioner "local-exec" {
#     command = "echo '${self.triggers.res_name}.privatelink.ibi.westus2.azmk8s.io ${self.triggers.host_name}' | sudo tee -a /etc/hosts"
#   }

#   provisioner "local-exec" {
#     when    = destroy
#     command = <<EOT
#       #!/bin/bash
#       host_entry="${self.triggers.res_name}.privatelink.ibi.westus2.azmk8s.io ${self.triggers.host_name}"
#       if grep -qF "$host_entry" /etc/hosts; then
#         sudo sed -i "/$host_entry/d" /etc/hosts
#       fi
#     EOT
#   }
# }
