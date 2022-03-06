# Prepare the group variable template with the right username and password
data "template_file" "ansible-group-vars" {
  template = "${file("../Ansible/group_vars/all.tmpl")}"

  depends_on = [
    var.windows-user,
    var.domain-dns-name,
    random_string.adminpass
  ]
  
  vars = {
    username    = var.windows-user
    password    = random_string.adminpass.result
    domain_name = var.domain-dns-name
  }
}

resource "null_resource" "ansible-group-vars-creation" {
  triggers = {
    template_rendered = "${data.template_file.ansible-group-vars.rendered}"
  }
  
  provisioner "local-exec" {
    command = "echo '${data.template_file.ansible-group-vars.rendered}' > ../Ansible/group_vars/all.yml"
  }
}


# Provision the lab using Ansible from the Debian machine
resource "null_resource" "ansible-provisioning" {

  # All VMs have to be up before provisioning can be initiated, and we always trigger
  triggers = {
    always_run = "${timestamp()}"
    dc_id = azurerm_windows_virtual_machine.cloudlabs-vm-dc.id
    winserv2019_id = azurerm_windows_virtual_machine.cloudlabs-vm-winserv2019.id
    windows10_id = azurerm_windows_virtual_machine.cloudlabs-vm-windows10.id
    debian_id = azurerm_linux_virtual_machine.cloudlabs-vm-debian.id
  }

  connection {
    type  = "ssh"
    host  = azurerm_public_ip.cloudlabs-ip.ip_address
    user  = var.debian-user
    agent = true
  }

  # Copy Ansible folder to debian machine for provisioning
  provisioner "file" {
    source      = "../Ansible"
    destination = "/dev/shm"
  }

  # Kick off ansible
  provisioner "remote-exec" {
    inline = [
      "sudo apt -qq update >/dev/null && sudo apt -qq install -y git ansible >/dev/null",
      "ansible-galaxy collection install ansible.windows >/dev/null",
      "cd /dev/shm/Ansible",
      "ansible-playbook -v cloudlabs.yml"
    ]
  }
}