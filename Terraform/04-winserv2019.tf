# Network Interface
resource "azurerm_network_interface" "cloudlabs-vm-winserv2019-nic" {
  name                 = "CloudLabs-vm-winserv2019-nic"
  location             = data.azurerm_resource_group.cloudlabs-rg.location
  resource_group_name  = data.azurerm_resource_group.cloudlabs-rg.name

  ip_configuration {
    name                          = "CloudLabs-vm-debian-winserv2019-config"
    subnet_id                     = azurerm_subnet.cloudlabs-subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.13.37.100"
  }
}

resource "azurerm_network_interface_nat_rule_association" "cloudlabs-vm-winserv2019-nic-nat" {
  network_interface_id  = azurerm_network_interface.cloudlabs-vm-winserv2019-nic.id
  ip_configuration_name = "CloudLabs-vm-debian-winserv2019-config"
  nat_rule_id           = azurerm_lb_nat_rule.cloudlabs-lb-nat-http.id
}

# Virtual Machine
resource "azurerm_windows_virtual_machine" "cloudlabs-vm-winserv2019" {
  name                = "CloudLabs-vm-winserv2019"
  computer_name       = "winserv2019"
  size                = "Standard_B4ms"
  provision_vm_agent  = true
  enable_automatic_updates = true
  resource_group_name = data.azurerm_resource_group.cloudlabs-rg.name
  location            = data.azurerm_resource_group.cloudlabs-rg.location
  timezone            = var.timezone
  admin_username      = var.windows-user
  admin_password      = random_string.adminpass.result
  custom_data         = local.custom_data_content
  network_interface_ids = [
    azurerm_network_interface.cloudlabs-vm-winserv2019-nic.id,
  ]

  os_disk {
    name                 = "CloudLabs-vm-winserv2019-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  additional_unattend_content {
    setting = "AutoLogon"
    content = "<AutoLogon><Password><Value>${random_string.adminpass.result}</Value></Password><Enabled>true</Enabled><LogonCount>1</LogonCount><Username>${var.windows-user}</Username></AutoLogon>"
  }

  additional_unattend_content {
    setting = "FirstLogonCommands"
    content = "${file("${path.module}/files/FirstLogonCommands.xml")}"
  }
}