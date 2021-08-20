locals {
  prefix            = var.prefix
  resource_group    = ibm_resource_group.registry_rg.name
  resource_group_id = ibm_resource_group.registry_rg.id
  public_ssh_key    = var.public_ssh_key != null ? chomp(file(var.public_ssh_key)) : tls_private_key.installkey[0].public_key_openssh
  private_ssh_key   = var.private_ssh_key != null ? chomp(file(var.public_ssh_key)) : tls_private_key.installkey[0].private_key_pem
}

resource "random_string" "random" {
  length  = 4
  special = false
}

resource "random_password" "registry_password" {
  length  = 16
  special = false
}

# SSH Key for VMs
resource "tls_private_key" "installkey" {
  count     = var.public_ssh_key == null ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "write_private_key" {
  count           = var.public_ssh_key == null ? 1 : 0
  content         = tls_private_key.installkey[0].private_key_pem
  filename        = "${path.root}/.ssh/id_rsa"
  file_permission = 0600
}

resource "local_file" "write_public_key" {
  count           = var.public_ssh_key == null ? 1 : 0
  content         = local.public_ssh_key
  filename        = "${path.root}/.ssh/id_rsa.pub"
  file_permission = 0600
}

resource "ibm_resource_group" "registry_rg" {
  name = "${var.prefix}-${random_string.random.result}-rg"
}

resource "ibm_is_ssh_key" "key" {
  name       = lower("${var.prefix}-${random_string.random.result}-sshkey")
  public_key = local.public_ssh_key
}

data "ibm_resource_group" "cluster_rg" {
  name = var.preexisting_cluster_resource_group_name
}

data "ibm_container_vpc_cluster" "cluster" {
  name              = var.preexisting_roks_cluster_name
  resource_group_id = data.ibm_resource_group.cluster_rg.id
}

module "vpc" {
  source            = "./vpc"
  region            = var.region
  prefix            = local.prefix
  resource_group_id = ibm_resource_group.registry_rg.id
  registry_vpc_cidr = var.registry_vpc_cidr
  cluster_api_port  = split(":", data.ibm_container_vpc_cluster.cluster.public_service_endpoint_url)[2]
}

module "diskencryption" {
  source            = "./diskencryption"
  region            = var.region
  resource_group_id = local.resource_group_id
  prefix            = local.prefix
}

module "bastion" {
  depends_on = [
    module.diskencryption
  ]
  source            = "./bastion"
  region            = var.region
  resource_group_id = local.resource_group_id
  subnet_id         = module.vpc.bastion_subnet_id
  vpc_id            = module.vpc.registry_vpc_id
  ssh_key_id        = ibm_is_ssh_key.key.id
  vm_profile        = var.bastion_vm_size
  security_group_id = module.vpc.bastion_security_group_id
  encryption_key    = module.diskencryption.encryption_key
}

module "registry" {
  depends_on = [
    module.diskencryption
  ]
  source            = "./registry"
  region            = var.region
  resource_group_id = local.resource_group_id
  subnet_id         = module.vpc.registry_subnet_id
  vpc_id            = module.vpc.registry_vpc_id
  ssh_key_id        = ibm_is_ssh_key.key.id
  vm_profile        = var.registry_vm_size
  security_group_id = module.vpc.registry_security_group_id
  encryption_key    = module.diskencryption.encryption_key
}

module "bastion_playbook" {
  depends_on = [
    module.bastion,
    module.vpc
  ]
  source              = "../common/ansible"
  playbook_path       = var.playbook_path
  playbook            = "bastion.yaml"
  username            = var.username
  private_ssh_key     = local.private_ssh_key
  bastion_host_public = module.bastion.public_ip
  inventory = templatefile("${var.inventory_path}/bastion_inventory.tmpl", {
    registry_host       = module.registry.private_ip
    bastion_host        = module.bastion.private_ip
    username            = var.username
    disk_device         = var.disk_device
    volume_name         = var.volume_name
    data_dir            = var.extra_disk_mountpoint
    bastion_host_public = module.bastion.public_ip
    compose_version     = var.compose_version
    harbor_version      = var.harbor_version
    openshift_version   = var.openshift_version
    cloudctl_version    = var.cloudctl_version
    platform            = var.cloud_platform
  })
}

module "copydisk" {
  source = "./copydisk"
  depends_on = [
    module.bastion,
    module.bastion_playbook
  ]
  encryption_key = module.diskencryption.encryption_key
  data_disk_size = 1024
  source_disk_id = module.bastion.data_disk_id
  target_vm_id   = module.registry.vm_id
}

module "registry_playbook" {
  depends_on = [
    module.registry,
    module.copydisk
  ]
  source              = "../common/ansible"
  playbook_path       = var.playbook_path
  playbook            = "registry.yaml"
  username            = var.username
  private_ssh_key     = local.private_ssh_key
  bastion_host_public = module.bastion.public_ip
  inventory = templatefile("${var.inventory_path}/registry_inventory.tmpl", {
    registry_host     = module.registry.private_ip
    bastion_host      = module.bastion.private_ip
    username          = var.username
    disk_device       = var.disk_device
    volume_name       = var.volume_name
    data_dir          = var.extra_disk_mountpoint
    registry_password = random_password.registry_password.result
    platform          = var.cloud_platform
  })
}

module "harbor_playbook" {
  depends_on = [
    module.registry_playbook
  ]
  source              = "../common/ansible"
  playbook_path       = var.playbook_path
  playbook            = "harbor.yaml"
  username            = var.username
  private_ssh_key     = local.private_ssh_key
  bastion_host_public = module.bastion.public_ip
  inventory = templatefile("${var.inventory_path}/harbor_inventory.tmpl", {
    username               = var.username
    registry_host          = module.registry.private_ip
    bastion_host           = module.bastion.private_ip
    registry_password      = random_password.registry_password.result
    registry_namespaces    = "[${join(", ", formatlist("'%s'", var.registry_namespaces))}]"
    keep_operators         = "[${join(", ", formatlist("'%s'", var.keep_operators))}]"
    openshift_version      = var.openshift_version
    openshift_pull_secret  = base64encode(file(var.openshift_pull_secret))
    openshift_product_repo = var.openshift_product_repo
    openshift_architecture = var.openshift_architecture
    openshift_release_name = var.openshift_release_name
    mirror_olm             = var.openshift_mirror_olm
    mirror_platform        = var.openshift_mirror_platform
    case_name              = var.case_name
    case_version           = var.case_version
    case_repo_path         = var.case_repo_path
    case_inventory_setup   = var.case_inventory_setup
    entitlement_key        = var.entitlement_key
    data_dir               = var.extra_disk_mountpoint
    platform               = var.cloud_platform
  })
}

module "peering" {
  source = "./peering"
  depends_on = [
    module.harbor_playbook
  ]
  region = var.region

  registry_rg  = local.resource_group_id
  registry_vpc = module.vpc.registry_vpc_name

  cluster_rg  = var.preexisting_cluster_resource_group_name
  cluster_vpc = var.preexisting_virtual_network_name
}

module "openshift" {
  depends_on = [
    module.peering
  ]
  source              = "../common/ansible"
  playbook_path       = var.playbook_path
  playbook            = "openshift.yaml"
  username            = var.username
  private_ssh_key     = local.private_ssh_key
  bastion_host_public = module.bastion.public_ip
  inventory = templatefile("${var.inventory_path}/openshift_inventory_roks.tmpl", {
    username             = var.username
    registry_host        = module.registry.private_ip
    bastion_host         = module.bastion.private_ip
    public_ssh_key       = local.public_ssh_key
    data_dir             = var.extra_disk_mountpoint
    case_name            = var.case_name
    case_version         = var.case_version
    case_inventory_setup = var.case_inventory_setup
    registry_password    = random_password.registry_password.result
    ibmcloud_api_key     = var.ibmcloud_api_key
    ibmcloud_version     = var.ibmcloud_version
    roks_cluster_id      = data.ibm_container_vpc_cluster.cluster.id
    mirror_olm           = var.openshift_mirror_olm
    mirror_platform      = var.openshift_mirror_platform
    platform             = var.cloud_platform
  })
}
