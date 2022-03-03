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

resource "azurerm_lb_rule" "cloudlabs-lb-rule-http" {
  resource_group_name            = azurerm_resource_group.cloudlabs-rg.name
  loadbalancer_id                = azurerm_lb.cloudlabs-lb.id
  name                           = "HTTPAccess"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
}

resource "azurerm_lb_nat_rule" "cloudlabs-lb-nat-ssh" {
  resource_group_name            = azurerm_resource_group.cloudlabs-rg.name
  loadbalancer_id                = azurerm_lb.cloudlabs-lb.id
  name                           = "SSHAccess"
  protocol                       = "Tcp"
  frontend_port                  = 22
  backend_port                   = 22
  frontend_ip_configuration_name = "CloudLabs-lb-ip-public"
}

resource "azurerm_lb_nat_rule" "cloudlabs-lb-nat-rdp" {
  resource_group_name            = azurerm_resource_group.cloudlabs-rg.name
  loadbalancer_id                = azurerm_lb.cloudlabs-lb.id
  name                           = "RDPAccess"
  protocol                       = "Tcp"
  frontend_port                  = 3389
  backend_port                   = 3389
  frontend_ip_configuration_name = "CloudLabs-lb-ip-public"
}

# Create NAT gateway for outbound internet access
resource "azurerm_nat_gateway" "cloudlabs-nat-gateway" {
  name                    = "CloudLabs-nat-gateway"
  location                = azurerm_resource_group.cloudlabs-rg.region
  resource_group_name     = azurerm_resource_group.cloudlabs-rg.name
}

resource "azurerm_nat_gateway_public_ip_association" "cloudlabs-nat-gateway-ip" {
  nat_gateway_id       = azurerm_nat_gateway.cloudlabs-nat-gateway.id
  public_ip_address_id = azurerm_public_ip.cloudlabs-ip.id
}


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
# DEBIAN ATTACKER BOX [10.13.37.200]
#

# Network Interface
resource "azurerm_network_interface" "cloudlabs-vm-debian-nic" {
  name                = "CloudLabs-vm-debian-nic"
  location            = azurerm_resource_group.cloudlabs-rg.region
  resource_group_name = azurerm_resource_group.cloudlabs-rg.name

  ip_configuration {
    name                          = "CloudLabs-vm-debian-nic-config"
    subnet_id                     = azurerm_subnet.cloudlabs-subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.13.37.200"
  }
}

resource "azurerm_network_interface_nat_rule_association" "cloudlabs-vm-debian-nic-nat" {
  network_interface_id  = azurerm_network_interface.cloudlabs-vm-debian-nic.id
  ip_configuration_name = "CloudLabs-vm-debian-nic-nat"
  nat_rule_id           = azurerm_lb_nat_rule.cloudlabs-lb-nat-ssh.id
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "cloudlabs-vm-debian" {
  name                = "CloudLabs-vm-debian"
  resource_group_name = azurerm_resource_group.cloudlabs-rg.name
  location            = azurerm_resource_group.cloudlabs-rg.region
  size                = "Standard_B2s"
  admin_username      = "hacker"
  network_interface_ids = [
    azurerm_network_interface.cloudlabs-vm-debian-nic.id,
  ]

  admin_ssh_key {
    username   = "hacker"
    public_key = var.public-key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Debian"
    offer     = "debian-11"
    sku       = "11-gen2"
    version   = "latest"
  }
}