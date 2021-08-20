resource "ibm_is_floating_ip" "bastion_public" {
  name   = "bastion-floating-ip"
  target = ibm_is_instance.bastion.primary_network_interface[0].id
}

data "ibm_is_image" "ubuntu" {
  name = "ibm-ubuntu-20-04-minimal-amd64-2"
}

resource "ibm_is_volume" "data_volume" {
  resource_group = var.resource_group_id
  name           = "bastion-data-disk"
  profile        = "10iops-tier"
  zone           = "${var.region}-1"
  capacity       = 1024
  encryption_key = var.encryption_key
}

resource "ibm_is_instance" "bastion" {
  name           = "bastion"
  resource_group = var.resource_group_id
  image          = data.ibm_is_image.ubuntu.id
  profile        = var.vm_profile

  boot_volume {
    encryption = var.encryption_key
  }

  primary_network_interface {
    subnet          = var.subnet_id
    security_groups = [var.security_group_id]
  }
  vpc  = var.vpc_id
  zone = "${var.region}-1"
  keys = [var.ssh_key_id]
}

resource "ibm_is_instance_volume_attachment" "data_attachment" {
  instance                           = ibm_is_instance.bastion.id
  name                               = "bastion-data-attachment"
  volume                             = ibm_is_volume.data_volume.id
  delete_volume_on_attachment_delete = true
  delete_volume_on_instance_delete   = true
}
