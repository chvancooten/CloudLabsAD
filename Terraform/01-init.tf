# Terraform initialization
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.98.0"
    }
  }

  required_version = ">= 1.1.5"
}

provider "azurerm" {
  skip_provider_registration = true
  features {}
}

# Add the specified SSH key to SSH-agent
resource "null_resource" "ssh-add" {
  provisioner "local-exec" {
    # Bootstrap script called with private_ip of each node in the cluster
    inline = [
      "eval `ssh-agent`",
      "ssh-add ${var.private-key-path}"
    ]
  }
}

# Generate random password for windows local admins
resource "random_string" "adminpass" {
  length           = 16
  special          = true
  override_special = "_%@"
}

# Get a reference to the existing resource group
data "azurerm_resource_group" "cloudlabs-rg" {
  name = var.resource-group
}