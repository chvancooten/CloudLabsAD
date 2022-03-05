# Prepare the group variable template with the right username and password
data "template_file" "ansible-group-vars" {
  template = "${file("../Ansible/group_vars/all.tmpl")}"
  depends_on = [
    var.windows-user,
    random_string.adminpass.result
  ]
  
  vars = {
    username = var.windows-user
    password = random_string.adminpass.result
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

  connection {
    type        = "ssh"
    host        = azurerm_public_ip.cloudlabs-ip.ip_address
    user        = var.debian-user
    private_key = file(var.private-key-path)
  }

  # Copy Ansible folder to debian machine for provisioning
  provisioner "file" {
    source      = "../Ansible"
    destination = "/dev/shm"
  }

  # Kick off ansible
  provisioner "remote-exec" {
    inline = [
      "sudo apt -qq update && sudo apt -qq install -y git ansible",
      "cd /dev/shm/Ansible",
      "ansible-playbook -v cloudlabs.yml"
    ]
  }
}