locals {
  basedir = element(split("/", var.playbook_path), length(split("/", var.playbook_path)) - 1)
}

resource "null_resource" "run_playbook" {
  connection {
    type        = "ssh"
    user        = var.username
    host        = var.bastion_host_public
    private_key = var.private_ssh_key
  }

  provisioner "file" {
    source      = var.playbook_path
    destination = "/home/${var.username}"
  }

  provisioner "file" {
    content     = var.inventory
    destination = "/home/${var.username}/inventory"
  }

  provisioner "file" {
    source      = "${path.root}/.ssh"
    destination = "/home/${var.username}/"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 /home/${var.username}/.ssh/id_rsa*",
      "which ansible-playbook || {",
      "  sudo apt update",
      "  sudo apt install python3-pip python3-jmespath -y",
      "  sudo -H pip3 install ansible -q",
      "}",
      "export ANSIBLE_PIPELINING=$(sudo grep requiretty /etc/sudoers && echo 0 || echo 1)",
      "ansible-playbook -i /home/${var.username}/inventory /home/${var.username}/${local.basedir}/${var.playbook}"
    ]
  }
}

