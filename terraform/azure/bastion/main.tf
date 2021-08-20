resource "azurerm_public_ip" "public_ip" {
  name                = "${var.prefix}-bastion-public-ip"
  location            = var.region
  resource_group_name = var.resource_group
  allocation_method   = "Static"
  sku                 = "standard"
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.prefix}-bastion-nic"
  location            = var.region
  resource_group_name = var.resource_group

  ip_configuration {
    primary                       = true
    name                          = "${var.prefix}-bastion-ip-configuration"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "bastion"
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

resource "azurerm_managed_disk" "data_disk" {
  name                   = "${var.prefix}-bastion-data"
  location               = var.region
  resource_group_name    = var.resource_group
  storage_account_type   = "Premium_LRS"
  create_option          = "Empty"
  disk_size_gb           = var.data_disk_size
  disk_encryption_set_id = var.encryption_set_id
}

resource "azurerm_virtual_machine_data_disk_attachment" "data_disk" {
  depends_on = [
    azurerm_linux_virtual_machine.vm
  ]
  managed_disk_id    = azurerm_managed_disk.data_disk.id
  virtual_machine_id = azurerm_linux_virtual_machine.vm.id
  lun                = "10"
  caching            = "ReadWrite"
}
