resource "azurerm_network_interface" "nic" {
  name                = "${var.prefix}-registry-nic"
  location            = var.region
  resource_group_name = var.resource_group

  ip_configuration {
    primary                       = true
    name                          = "${var.prefix}-registry-ip-configuration"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "registry"
  resource_group_name = var.resource_group
  location            = var.region
  size                = var.vm_size
  admin_username      = var.username
  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  admin_ssh_key {
    username   = var.username
    public_key = var.public_ssh_key
  }

  os_disk {
    caching                = "ReadWrite"
    storage_account_type   = "Standard_LRS"
    disk_encryption_set_id = var.encryption_set_id
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}
