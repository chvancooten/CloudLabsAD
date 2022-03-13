output "region" {
  value = data.azurerm_resource_group.cloudlabs-rg.location
  description = "The region in which the resources are deployed. Based on the configured resource group."
}

output "public-ip" {
  value = azurerm_public_ip.cloudlabs-ip.ip_address
  description = "The public IP address used to connect to the lab."
}

output "public-ip-dns" {
  value = azurerm_public_ip.cloudlabs-ip.fqdn
  description = "The public DNS name used to connect to the lab."
}

output "public-ip-outbound" {
    value = azurerm_public_ip.cloudlabs-ip-outbound.ip_address
    description = "The public IP address used by the lab machines to reach the internet."
}

output "ip-whitelist" {
    value = join(", ", var.ip-whitelist)
    description = "The IP address(es) that are allowed to connect to the various lab interfaces."
}

output "linux-user" {
    value = var.linux-user
    description = "The SSH username used to connect to Linux machines."
}

output "linux-password" {
    value = random_string.linuxpass.result
    description = "The password used for Linux admin accounts."
}

output  "windows-domain" {
    value = var.domain-dns-name
    description = "The the Active Directory domain name."
}

output "windows-user" {
    value = var.windows-user
    description = "The username used to connect to the Windows machine."
}

output "windows-password" {
    value = random_string.windowspass.result
    description = "The password used for Windows local admin accounts."
}

output "hackbox-hostname" {
    value = var.hackbox-hostname
    description = "The hostname of the attacker VM."
}

output "elastic-hostname" {
    value = var.elastic-hostname
    description = "The hostname of the Elastic VM."
}

output "dc-hostname" {
    value = var.dc-hostname
    description = "The hostname of the Domain Controller."
}

output "winserv2019-hostname" {
    value = var.winserv2019-hostname
    description = "The hostname of the Windows Server 2019 VM."
}

output "win10-hostname"{
    value = var.win10-hostname
    description = "The hostname of the Windows 10 VM."
}