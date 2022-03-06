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

variable "debian-hostname" {
  type = string
  description = "The hostname of the Debian VM."
  default = "hackbox"
}

variable "dc-hostname" {
  type = string
  description = "The hostname of the Windows Server 2016 DC VM."
  default = "dc"
}

variable "winserv2019-hostname" {
  type = string
  description = "The hostname of the Windows Server 2019 VM."
  default = "winserv2019"
}

variable "win10-hostname" {
  type = string
  description = "The hostname of the Windows 10 VM."
  default = "win10"
}

variable "windows-user" {
  type        = string
  description = "The local administrative username for Windows machines. Password will be generated."
  default     = "labadmin"
}  

variable "debian-user" {
  type        = string
  description = "The username used to access the Debian machine via SSH."
  default     = "hacker"
}

variable "public-key" {
  type        = string
  description = "The public key used to access the Debian machine via SSH."
}