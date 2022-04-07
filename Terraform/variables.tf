variable "resource-group" {
  type        = string
  description = "The name of the sandbox resource group."
}

variable "timezone" {
  type        = string
  description = "The timezone of the lab VMs."
  default     = "W. Europe Standard Time"
}

variable "ip-whitelist" {
  description = "A list of CIDRs that will be allowed to access the exposed services."
  type        = list(string)
}

variable "domain-name-label" {
  description = "The DNS name of the Azure public IP."
  type        = string
  default     = "cloudlabs"
}

variable "domain-dns-name" {
  description = "The DNS name of the Active Directory domain."
  type        = string
  default     = "cloud.labs"
}

variable "hackbox-hostname" {
  type = string
  description = "The hostname of the attacker VM."
  default = "hackbox"
}

variable "hackbox-size" {
  type = string
  description = "The machine size of the attacker VM."
  default = "Standard_B4ms"
}

variable "elastic-hostname" {
  type = string
  description = "The hostname of the Elastic VM."
  default = "elastic"
}

variable "elastic-size" {
  type = string
  description = "The machine size of the Elastic VM."
  default = "Standard_B4ms"
}

variable "dc-hostname" {
  type = string
  description = "The hostname of the Windows Server 2016 DC VM."
  default = "dc"
}

variable "dc-size" {
  type = string
  description = "The machine size of the Windows Server 2016 DC VM."
  default = "Standard_B4ms"
}

variable "winserv2019-hostname" {
  type = string
  description = "The hostname of the Windows Server 2019 VM."
  default = "winserv2019"
}

variable "winserv2019-size" {
  type = string
  description = "The machine size of the Windows Server 2019 VM."
  default = "Standard_B4ms"
}

variable "win10-hostname" {
  type = string
  description = "The hostname of the Windows 10 VM."
  default = "win10"
}

variable "win10-size" {
  type = string
  description = "The machine size of the Windows 10 VM."
  default = "Standard_B4ms"
}

variable "windows-user" {
  type        = string
  description = "The local administrative username for Windows machines. Password will be generated."
  default     = "labadmin"
}  

variable "linux-user" {
  type        = string
  description = "The username used to access Linux machines via SSH."
  default     = "labadmin"
}