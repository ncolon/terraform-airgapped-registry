resource "azurerm_network_security_group" "nsg" {
  count = 1

  name                = "${var.prefix}-nsg"
  location            = var.region
  resource_group_name = var.resource_group
}

resource "azurerm_subnet_network_security_group_association" "bastion" {
  # count = var.preexisting_network ? 0 : 1
  count = 1

  subnet_id                 = local.bastion_subnet_id
  network_security_group_id = azurerm_network_security_group.nsg[0].id
}

resource "azurerm_subnet_network_security_group_association" "registry" {
  # count = var.preexisting_network ? 0 : 1
  count = 1

  subnet_id                 = azurerm_subnet.registry_subnet[0].id
  network_security_group_id = azurerm_network_security_group.nsg[0].id
}

resource "azurerm_network_security_rule" "ssh_internet" {
  # count = var.preexisting_nsg ? 0 : 1
  count = 1

  name                        = "ssh_internet"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "Internet"
  destination_address_prefix  = local.bastion_subnet
  resource_group_name         = var.resource_group
  network_security_group_name = azurerm_network_security_group.nsg[0].name
}

resource "azurerm_network_security_rule" "ssh_local" {
  # count = var.preexisting_nsg ? 0 : 1

  name                        = "ssh_local"
  priority                    = 102
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = var.resource_group
  network_security_group_name = azurerm_network_security_group.nsg[0].name
}

resource "azurerm_network_security_rule" "https_internet_to_bastion" {
  # count = var.preexisting_nsg ? 0 : 1

  name                        = "https_internet_to_bastion"
  priority                    = 103
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "Internet"
  destination_address_prefix  = local.bastion_subnet
  resource_group_name         = var.resource_group
  network_security_group_name = azurerm_network_security_group.nsg[0].name
}

resource "azurerm_network_security_rule" "https_local_vnet" {
  # count = var.preexisting_nsg ? 0 : 1

  name                        = "https_local_vnet"
  priority                    = 104
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = var.resource_group
  network_security_group_name = azurerm_network_security_group.nsg[0].name
}

resource "azurerm_network_security_rule" "deny_all_registry" {
  # count = var.preexisting_nsg ? 0 : 1

  name                        = "deny_all_registry"
  priority                    = 105
  direction                   = "Outbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = local.registry_subnet
  destination_address_prefix  = "Internet"
  resource_group_name         = var.resource_group
  network_security_group_name = azurerm_network_security_group.nsg[0].name
}
