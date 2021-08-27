locals {
  basedir            = element(split("/", var.playbook_path), length(split("/", var.playbook_path)) - 1)
  playbook_workspace = var.playbook_workspace != "" ? var.playbook_workspace : "/home/${var.username}"
}

resource "null_resource" "upload_artifacts" {
  count = var.upload_files != "" ? 1 : 0
  connection {
    type        = "ssh"
    user        = var.username
    host        = var.bastion_host_public
    private_key = var.private_ssh_key
  }

  provisioner "file" {
    source      = var.upload_files
    destination = local.playbook_workspace
  }
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
    destination = local.playbook_workspace
  }

  provisioner "file" {
    content     = var.inventory
    destination = "${local.playbook_workspace}/inventory"
  }

  provisioner "file" {
    source      = "${path.root}/.ssh"
    destination = local.playbook_workspace
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 600 ${local.playbook_workspace}/.ssh/id_rsa*",
      "export PATH=$PATH:/usr/local/bin",
      "which ansible-playbook || {",
      "  sudo apt update",
      "  sudo apt install python3-pip python3-jmespath -y",
      "  sudo -H pip3 install ansible openshift -q",
      "}",
      "export ANSIBLE_PIPELINING=$(sudo grep requiretty /etc/sudoers && echo 0 || echo 1)",
      "ansible-playbook --private-key ${local.playbook_workspace}/.ssh/id_rsa -i ${local.playbook_workspace}/inventory ${local.playbook_workspace}/${local.basedir}/${var.playbook}"
    ]
  }
}

