resource "azurerm_managed_disk" "data_disk" {
  name                   = "${var.prefix}-registry-data"
  location               = var.region
  resource_group_name    = var.resource_group
  storage_account_type   = "Premium_LRS"
  create_option          = "Copy"
  disk_size_gb           = var.data_disk_size
  source_resource_id     = var.source_disk_id
  disk_encryption_set_id = var.encryption_set_id
}

resource "azurerm_virtual_machine_data_disk_attachment" "data_disk" {
  managed_disk_id    = azurerm_managed_disk.data_disk.id
  virtual_machine_id = var.target_vm_id
  lun                = "10"
  caching            = "ReadWrite"
}
