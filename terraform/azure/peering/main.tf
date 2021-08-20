data "azurerm_virtual_network" "cluster_vnet" {
  name                = var.cluster_vnet
  resource_group_name = var.network_rg
}

data "azurerm_virtual_network" "registry_vnet" {
  name                = var.registry_vnet
  resource_group_name = var.registry_rg
}

resource "azurerm_virtual_network_peering" "registry_to_cluster" {
  name                      = "peering-registry-to-cluster"
  resource_group_name       = var.registry_rg
  virtual_network_name      = data.azurerm_virtual_network.registry_vnet.name
  remote_virtual_network_id = data.azurerm_virtual_network.cluster_vnet.id
}

resource "azurerm_virtual_network_peering" "cluster_to_registry" {
  name                      = "peering-cluster-to-registry"
  resource_group_name       = var.network_rg
  virtual_network_name      = data.azurerm_virtual_network.cluster_vnet.name
  remote_virtual_network_id = data.azurerm_virtual_network.registry_vnet.id
}

# Moved to ansible playbook via azure-cli since domain gets created mid-flight
# data "azurerm_private_dns_zone" "private_dns" {
#   name                = "${var.cluster_name}.${var.openshift_base_domain}"
#   resource_group_name = var.cluster_rg
# }

# resource "azurerm_private_dns_zone_virtual_network_link" "network" {
#   name                  = "registry-network-link"
#   resource_group_name   = var.cluster_rg
#   private_dns_zone_name = data.azurerm_private_dns_zone.private_dns.name
#   virtual_network_id    = data.azurerm_virtual_network.registry_vnet.id
# }
