data "ibm_is_vpc" "cluster_vpc" {
  name = var.cluster_vpc
}

data "ibm_is_vpc" "registry_vpc" {
  name = var.registry_vpc
}

resource "ibm_tg_gateway" "transit_gateway" {
  name           = "cluster-registry-transit-gateway"
  location       = var.region
  global         = true
  resource_group = var.registry_rg
}

resource "ibm_tg_connection" "connection-to-cluster" {
  gateway      = ibm_tg_gateway.transit_gateway.id
  network_type = "vpc"
  name         = "connection-to-cluster"
  network_id   = data.ibm_is_vpc.cluster_vpc.resource_crn
  lifecycle {
    ignore_changes = [
      updated_at,
    ]
  }
}

resource "ibm_tg_connection" "connection-to-registry" {
  gateway      = ibm_tg_gateway.transit_gateway.id
  network_type = "vpc"
  name         = "connection-to-registry"
  network_id   = data.ibm_is_vpc.registry_vpc.resource_crn
  lifecycle {
    ignore_changes = [
      updated_at,
    ]
  }
}

