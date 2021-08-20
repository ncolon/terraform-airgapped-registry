resource "azurerm_virtual_network" "registry_vnet" {
  count = 1

  name                = "${var.prefix}-vnet"
  resource_group_name = var.resource_group
  location            = var.region
  address_space       = [var.vnet_cidr]
}

resource "azurerm_subnet" "bastion_subnet" {
  count = 1

  resource_group_name  = var.resource_group
  virtual_network_name = local.registry_vnet_name
  name                 = "${var.prefix}-bastion-subnet"
  address_prefixes     = [local.bastion_subnet]
}

resource "azurerm_subnet" "registry_subnet" {
  count = 1

  resource_group_name  = var.resource_group
  virtual_network_name = local.registry_vnet_name
  name                 = "${var.prefix}-registry-subnet"
  address_prefixes     = [local.registry_subnet]
}
