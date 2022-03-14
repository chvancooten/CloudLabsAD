# Network Interface
resource "azurerm_network_interface" "cloudlabs-vm-elastic-nic" {
  name                = "CloudLabs-vm-elastic-nic"
  location            = data.azurerm_resource_group.cloudlabs-rg.location
  resource_group_name = data.azurerm_resource_group.cloudlabs-rg.name

  ip_configuration {
    name                          = "CloudLabs-vm-elastic-nic-config"
    subnet_id                     = azurerm_subnet.cloudlabs-subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.13.37.50"
  }
}

resource "azurerm_network_interface_nat_rule_association" "cloudlabs-vm-elastic-nic-nat" {
  network_interface_id  = azurerm_network_interface.cloudlabs-vm-elastic-nic.id
  ip_configuration_name = "CloudLabs-vm-elastic-nic-config"
  nat_rule_id           = azurerm_lb_nat_rule.cloudlabs-lb-nat-ssh.id
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "cloudlabs-vm-elastic" {
  name                = "CloudLabs-vm-elastic"
  computer_name       = var.elastic-hostname
  resource_group_name = data.azurerm_resource_group.cloudlabs-rg.name
  location            = data.azurerm_resource_group.cloudlabs-rg.location
  size                = "Standard_D4ds_v5"
  disable_password_authentication = false
  admin_username      = var.linux-user
  admin_password      = random_string.linuxpass.result
  network_interface_ids = [
    azurerm_network_interface.cloudlabs-vm-elastic-nic.id,
  ]

  os_disk {
    name                 = "CloudLabs-vm-elastic-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Debian"
    offer     = "debian-11"
    sku       = "11-gen2"
    version   = "latest"
  }

  tags = {
    DoNotAutoShutDown = "yes"
  }
}