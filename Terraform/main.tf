#
# INITIALIZATION
#

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

# Get a reference to the existing resource group
data "azurerm_resource_group" "cloudlabs-rg" {
  name = var.rg
}


#
# NETWORKING
#

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "cloudlabs-vnet" {
  name                = "CloudLabs-vnet"
  resource_group_name = azurerm_resource_group.cloudlabs-rg.name
  location            = azurerm_resource_group.cloudlabs-rg.region
  address_space       = ["10.0.0.0/8"]
}

# Create a subnet within the virtual network
resource "azurerm_subnet" "cloudlabs-subnet" {
  name                 = "CloudLabs-subnet"
  resource_group_name  = azurerm_resource_group.cloudlabs-rg.name
  virtual_network_name = azurerm_virtual_network.cloudlabs-vnet.name
  address_prefixes     = ["10.13.37.0/24"]
}

# Create a network security group for the subnet
resource "azurerm_network_security_group" "cloudlabs-nsg" {
  name                = "CloudLabs-nsg"
  location            = azurerm_resource_group.cloudlabs-rg.region
  resource_group_name = azurerm_resource_group.cloudlabs-rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = var.ip-whitelist
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefixes    = var.ip-whitelist
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "RDP"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefixes    = var.ip-whitelist
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Internal"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "10.13.37.0/24"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "cloudlabs-nsga" {
  subnet_id                 = azurerm_subnet.cloudlabs-subnet.id
  network_security_group_id = azurerm_network_security_group.cloudlabs-nsg.id
}

# Create a public IP address for the lab
resource "azurerm_public_ip" "cloudlabs-ip" {
  name                = "CloudLabs-ip"
  location            = azurerm_resource_group.cloudlabs-rg.region
  resource_group_name = azurerm_resource_group.cloudlabs-rg.name
  allocation_method   = "Static"
  domain_name_label   = "cloudlabs"
}

# Create a load balancer on the public IP
resource "azurerm_lb" "cloudlabs-lb" {
  name                = "CloudLabs-lb"
  location            = azurerm_resource_group.cloudlabs-rg.region
  resource_group_name = azurerm_resource_group.cloudlabs-rg.name

  frontend_ip_configuration {
    name                 = "CloudLabs-lb-ip-public"
    public_ip_address_id = azurerm_public_ip.cloudlabs-ip.id
  }
}

# resource "azurerm_lb_backend_address_pool" "cloudlabs-lb-backend" {
#   name            = "CloudLabs-lb-backend"
#   loadbalancer_id = data.azurerm_lb.cloudlabs-lb.id
# }

# resource "azurerm_lb_backend_address_pool_address" "cloudlabs-lb-backend-ip" {
#   name                    = "CloudLabs-lb-backend-ip"
#   backend_address_pool_id = data.azurerm_lb_backend_address_pool.cloudlabs-lb-backend.id
#   virtual_network_id      = data.azurerm_virtual_network.cloudlabs-vnet.id
#   ip_address              = "10.0.0.250"
# }

resource "azurerm_lb_nat_rule" "cloudlabs-lb-nat-ssh" {
  resource_group_name            = azurerm_resource_group.cloudlabs-rg.name
  loadbalancer_id                = azurerm_lb.cloudlabs-lb.id
  name                           = "SSHAccess"
  protocol                       = "Tcp"
  frontend_port                  = 22
  backend_port                   = 22
  frontend_ip_configuration_name = "CloudLabs-lb-ip-public"
}

# Create NAT gateway for outbound internet access?
# https://docs.microsoft.com/en-us/azure/load-balancer/tutorial-load-balancer-port-forwarding-portal

#
# WINDOWS SERVER 2016 - DC [10.13.37.10]
# 


#
# WINDOWS SERVER 2019 - CA and IIS [10.13.37.100]
#


#
# WINDOWS 10 WORKSTATION [10.13.37.150]
# 


#
# KALI LINUX ATTACKER BOX [10.13.37.200]
#