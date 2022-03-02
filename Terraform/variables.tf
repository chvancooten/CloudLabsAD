variable "resource-group" {
    type = string
    description = "The name of the sandbox resource group"
}

variable "ip-whitelist" {
  description = "A list of CIDRs that will be allowed to access the instances"
  type        = list(string)
  default     = [""]
}