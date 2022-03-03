variable "resource-group" {
    type        = string
    description = "The name of the sandbox resource group"
}

variable "ip-whitelist" {
  description = "A list of CIDRs that will be allowed to access the exposed services"
  type        = list(string)
  default     = [""]
}

variable "ssh-user" {
    type        = string
    description = "The username used to access the Debian machine via SSH"
    default     = "hacker"
}

variable "public-key" {
    type        = string
    description = "The public key used to access the Debian machine via SSH"
}