# Network Interface
resource "azurerm_network_interface" "cloudlabs-vm-debian-nic" {
  name                = "CloudLabs-vm-debian-nic"
  location            = data.azurerm_resource_group.cloudlabs-rg.location
  resource_group_name = data.azurerm_resource_group.cloudlabs-rg.name

  ip_configuration {
    name                          = "CloudLabs-vm-debian-nic-config"
    subnet_id                     = azurerm_subnet.cloudlabs-subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.13.37.200"
  }
}

resource "azurerm_network_interface_nat_rule_association" "cloudlabs-vm-debian-nic-nat" {
  network_interface_id  = azurerm_network_interface.cloudlabs-vm-debian-nic.id
  ip_configuration_name = "CloudLabs-vm-debian-nic-config"
  nat_rule_id           = azurerm_lb_nat_rule.cloudlabs-lb-nat-ssh.id
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "cloudlabs-vm-debian" {
  name                = "CloudLabs-vm-debian"
  computer_name       = var.debian-hostname
  resource_group_name = data.azurerm_resource_group.cloudlabs-rg.name
  location            = data.azurerm_resource_group.cloudlabs-rg.location
  size                = "Standard_B2s"
  admin_username      = var.debian-user
  network_interface_ids = [
    azurerm_network_interface.cloudlabs-vm-debian-nic.id,
  ]

  admin_ssh_key {
    username   = var.debian-user
    public_key = var.public-key
  }

  os_disk {
    name                 = "CloudLabs-vm-debian-osdisk"
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