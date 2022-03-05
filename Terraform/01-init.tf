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

# Specify where the custom data file is for WinRM initialization
locals {
    custom_data_content  = file("${path.module}/files/ConfigureRemotingForAnsible.ps1")
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