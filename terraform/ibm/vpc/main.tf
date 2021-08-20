resource "ibm_is_vpc" "registry_vpc" {
  count = 1

  name                      = "${var.prefix}-vpc"
  resource_group            = var.resource_group_id
  address_prefix_management = "manual"
}

resource "ibm_is_vpc_address_prefix" "address_prefix" {
  count = 1

  name = "default"
  zone = "${var.region}-${count.index + 1}"
  vpc  = local.registry_vpc_id
  cidr = cidrsubnet(var.registry_vpc_cidr, 2, count.index)
}

resource "ibm_is_public_gateway" "public_gateway" {
  count = 1

  name           = "${var.prefix}-public-gateway-${var.region}-${count.index + 1}"
  resource_group = var.resource_group_id
  vpc            = local.registry_vpc_id
  zone           = "${var.region}-${count.index + 1}"
}

resource "ibm_is_subnet" "bastion_subnet" {
  count = 1

  name            = "bastion-subnet"
  vpc             = local.registry_vpc_id
  zone            = "${var.region}-${count.index + 1}"
  ipv4_cidr_block = local.bastion_subnet
  public_gateway  = ibm_is_public_gateway.public_gateway[count.index].id
  depends_on = [
    ibm_is_vpc.registry_vpc
  ]
}

resource "ibm_is_subnet" "registry_subnet" {
  count = 1

  name            = "registry-subnet"
  vpc             = local.registry_vpc_id
  zone            = "${var.region}-${count.index + 1}"
  ipv4_cidr_block = local.registry_subnet
  depends_on = [
    ibm_is_vpc.registry_vpc
  ]
}
