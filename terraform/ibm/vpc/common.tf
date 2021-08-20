locals {
  registry_vpc_name          = ibm_is_vpc.registry_vpc[0].name
  registry_vpc_id            = ibm_is_vpc.registry_vpc[0].id
  bastion_subnet             = cidrsubnet(ibm_is_vpc_address_prefix.address_prefix[0].cidr, 2, 0)
  registry_subnet            = cidrsubnet(ibm_is_vpc_address_prefix.address_prefix[0].cidr, 2, 1)
  bastion_subnet_id          = ibm_is_subnet.bastion_subnet[0].id
  registry_subnet_id         = ibm_is_subnet.registry_subnet[0].id
  bastion_security_group_id  = ibm_is_security_group.bastion_internet[0].id
  registry_security_group_id = ibm_is_security_group.registry_local[0].id
}
