data "ibm_is_image" "ubuntu" {
  name = "ibm-ubuntu-20-04-minimal-amd64-2"
}

resource "ibm_is_instance" "registry" {
  name           = "registry"
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
