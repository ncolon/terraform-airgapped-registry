locals {
  prefix          = var.prefix
  resource_group  = azurerm_resource_group.registry_rg.name
  public_ssh_key  = var.public_ssh_key != null ? chomp(file(var.public_ssh_key)) : tls_private_key.installkey[0].public_key_openssh
  private_ssh_key = var.private_ssh_key != null ? chomp(file(var.public_ssh_key)) : tls_private_key.installkey[0].private_key_pem
}

resource "random_string" "random" {
  length  = 4
  special = false
}
resource "azurerm_resource_group" "registry_rg" {
  name     = "${var.prefix}-${random_string.random.result}-rg"
  location = var.region
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

resource "azurerm_ssh_public_key" "ssh_key" {
  name                = "${local.prefix}-ssh-key"
  resource_group_name = local.resource_group
  location            = var.region
  public_key          = local.public_ssh_key
}

resource "random_password" "registry_password" {
  length  = 16
  special = false
}


module "vnet" {
  source         = "./vnet"
  region         = var.region
  resource_group = local.resource_group
  vnet_cidr      = var.registry_network_cidr
  prefix         = local.prefix

}

module "diskencryption" {
  source         = "./diskencryption"
  region         = var.region
  resource_group = local.resource_group
  prefix         = local.prefix
}

module "bastion" {
  source            = "./bastion"
  prefix            = local.prefix
  region            = var.region
  resource_group    = local.resource_group
  subnet_id         = module.vnet.bastion_subnet_id
  vm_size           = var.bastion_vm_size
  username          = var.username
  public_ssh_key    = local.public_ssh_key
  private_ssh_key   = local.private_ssh_key
  encryption_set_id = module.diskencryption.encryption_set_id
  data_disk_size    = 1024
}

module "registry" {
  source            = "./registry"
  prefix            = local.prefix
  region            = var.region
  resource_group    = local.resource_group
  subnet_id         = module.vnet.registry_subnet_id
  vm_size           = var.registry_vm_size
  username          = var.username
  public_ssh_key    = local.public_ssh_key
  encryption_set_id = module.diskencryption.encryption_set_id
}

module "bastion_playbook" {
  depends_on = [
    module.bastion,
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
  prefix            = local.prefix
  region            = var.region
  resource_group    = local.resource_group
  encryption_set_id = module.diskencryption.encryption_set_id
  data_disk_size    = 1024
  source_disk_id    = module.bastion.data_disk_id
  target_vm_id      = module.registry.vm_id
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
    openshift_pull_secret  = base64encode(file(var.openshift_pull_secret))
    openshift_version      = var.openshift_version
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
  registry_rg   = local.resource_group
  registry_vnet = module.vnet.vnet_name

  cluster_rg   = var.preexisting_cluster_resource_group_name
  network_rg   = var.preexisting_network_resource_group_name
  cluster_vnet = var.preexisting_virtual_network_name
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
  inventory = templatefile("${var.inventory_path}/openshift_inventory_azure.tmpl", {
    username                                = var.username
    registry_host                           = module.registry.private_ip
    bastion_host                            = module.bastion.private_ip
    openshift_architecture                  = var.openshift_architecture
    openshift_version                       = var.openshift_version
    preexisting_cluster_resource_group_name = var.preexisting_cluster_resource_group_name
    openshift_base_domain                   = var.openshift_base_domain
    openshift_cluster_name                  = var.openshift_cluster_name
    openshift_worker_vm_type                = var.openshift_worker_vm_type
    openshift_worker_os_disk_size           = var.openshift_worker_os_disk_size
    openshift_worker_node_count             = var.openshift_worker_node_count
    openshift_master_vm_type                = var.openshift_master_vm_type
    openshift_master_os_disk_size           = var.openshift_master_os_disk_size
    openshift_cluster_network_cidr          = var.openshift_cluster_network_cidr
    openshift_cluster_network_host_prefix   = var.openshift_cluster_network_host_prefix
    openshift_machine_cidr                  = var.openshift_machine_cidr
    openshift_service_network_cidr          = var.openshift_service_network_cidr
    azure_outbound_type                     = var.azure_outbound_type
    openshift_azure_publish                 = var.openshift_azure_private ? "Internal" : "External"
    azure_region                            = var.region
    azure_subscription_id                   = var.subscription_id
    azure_tenant_id                         = var.tenant_id
    azure_client_id                         = var.client_id
    azure_client_secret                     = var.client_secret
    azure_dns_resource_group_name           = var.azure_dns_resource_group_name
    preexisting_network_resource_group_name = var.preexisting_network_resource_group_name
    preexisting_virtual_network_name        = var.preexisting_virtual_network_name
    preexisting_control_plane_subnet        = var.preexisting_control_plane_subnet
    preexisting_compute_subnet              = var.preexisting_compute_subnet
    registry_virtual_network_name           = module.vnet.vnet_name
    registry_resrouce_group_name            = local.resource_group
    public_ssh_key                          = local.public_ssh_key
    data_dir                                = var.extra_disk_mountpoint
    case_name                               = var.case_name
    case_version                            = var.case_version
    case_inventory_setup                    = var.case_inventory_setup
    registry_password                       = random_password.registry_password.result
    platform                                = var.cloud_platform
    mirror_olm                              = var.openshift_mirror_olm
    mirror_platform                         = var.openshift_mirror_platform
  })
}


