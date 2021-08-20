locals {
  bastion_subnet     = cidrsubnet(var.vnet_cidr, 3, 0)
  registry_subnet    = cidrsubnet(var.vnet_cidr, 3, 1)
  bastion_subnet_id  = azurerm_subnet.bastion_subnet[0].id
  registry_subnet_id = azurerm_subnet.registry_subnet[0].id
  registry_vnet_name = azurerm_virtual_network.registry_vnet[0].name
  registry_nsg_id    = azurerm_network_security_group.nsg[0].id
  vnet_name          = azurerm_virtual_network.registry_vnet[0].name
}
