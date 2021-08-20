resource "ibm_is_security_group" "bastion_internet" {
  count = 1

  name           = "${var.prefix}-bastion-internet-sg"
  resource_group = var.resource_group_id
  vpc            = local.registry_vpc_id
}

resource "ibm_is_security_group_rule" "ssh_internet_inbound" {
  group     = ibm_is_security_group.bastion_internet[0].id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 22
    port_max = 22
  }
}

resource "ibm_is_security_group_rule" "ssh_registry_outbound" {
  group     = ibm_is_security_group.bastion_internet[0].id
  direction = "outbound"
  remote    = local.registry_subnet
  tcp {
    port_min = 22
    port_max = 22
  }
}

resource "ibm_is_security_group_rule" "http_internet" {
  group     = ibm_is_security_group.bastion_internet[0].id
  direction = "outbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 80
    port_max = 80
  }
}

resource "ibm_is_security_group_rule" "https_internet" {
  group     = ibm_is_security_group.bastion_internet[0].id
  direction = "outbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 443
    port_max = 443
  }
}

resource "ibm_is_security_group_rule" "cse_dns_1" {
  group     = ibm_is_security_group.bastion_internet[0].id
  direction = "outbound"
  remote    = "161.26.0.10"
  udp {
    port_min = 53
    port_max = 53
  }
}

resource "ibm_is_security_group_rule" "cse_dns_2" {
  group     = ibm_is_security_group.bastion_internet[0].id
  direction = "outbound"
  remote    = "161.26.0.11"
  udp {
    port_min = 53
    port_max = 53
  }
}

resource "ibm_is_security_group_rule" "private_dns_1" {
  group     = ibm_is_security_group.bastion_internet[0].id
  direction = "outbound"
  remote    = "161.26.0.7"
  udp {
    port_min = 53
    port_max = 53
  }
}

resource "ibm_is_security_group_rule" "private_dns_2" {
  group     = ibm_is_security_group.bastion_internet[0].id
  direction = "outbound"
  remote    = "161.26.0.8"
  udp {
    port_min = 53
    port_max = 53
  }
}

resource "ibm_is_security_group" "registry_local" {
  count = 1

  name           = "${var.prefix}-registry-local-sg"
  resource_group = var.resource_group_id
  vpc            = local.registry_vpc_id
}

resource "ibm_is_security_group_rule" "ssh_local" {
  group     = ibm_is_security_group.registry_local[0].id
  direction = "inbound"
  remote    = local.bastion_subnet
  tcp {
    port_min = 22
    port_max = 22
  }
}

resource "ibm_is_security_group_rule" "https_local" {
  group     = ibm_is_security_group.registry_local[0].id
  direction = "inbound"
  remote    = "0.0.0.0/0"
  tcp {
    port_min = 443
    port_max = 443
  }
}

resource "ibm_is_security_group_rule" "bastion_to_cluster" {
  group     = ibm_is_security_group.bastion_internet[0].id
  direction = "outbound"
  tcp {
    port_min = var.cluster_api_port
    port_max = var.cluster_api_port
  }
}
