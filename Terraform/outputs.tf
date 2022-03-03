output "region" {
  value = data.azurerm_resource_group.cloudlabs-rg.location
  description = "The region in which the resources are deployed. Based on the configured resource group."
}

output "public-ip" {
  value = azurerm_public_ip.cloudlabs-ip.ip_address 
  description = "The public IP address used to connect to the lab."
}

output "ip-whitelist" {
    value = var.ip-whitelist
    description = "The IP address(es) that are allowed to connect to the various lab interfaces."
}

output "public-ip-outbound" {
    value = azurerm_public_ip.cloudlabs-ip-outbound.ip_address 
    description = "The public IP address used by the lab machines to reach the internet."
}

output "ssh-user" {
    value = var.ssh-user 
    description = "The SSH username used to connect to the Debian machine."
}