variable "cloud_platform" {
  type = string
}

variable "subscription_id" {
  type        = string
  description = "The subscription that should be used to interact with Azure API"
}

variable "client_id" {
  type        = string
  description = "The app ID that should be used to interact with Azure API"
}

variable "client_secret" {
  type        = string
  description = "The password that should be used to interact with Azure API"
}

variable "tenant_id" {
  type        = string
  description = "The tenant ID that should be used to interact with Azure API"
}

variable "environment" {
  type        = string
  description = "The target Azure cloud environment for the cluster."
  default     = "public"
}

variable "region" {
  type        = string
  description = "The target Azure region for the image registry."
}

variable "prefix" {
  type = string
}

variable "registry_vnet_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "bastion_vm_size" {
  type    = string
  default = "Standard_D8s_v3"
}

variable "registry_vm_size" {
  type    = string
  default = "Standard_D8s_v3"
}

variable "public_ssh_key" {
  type    = string
  default = null
}

variable "private_ssh_key" {
  type    = string
  default = null
}

variable "username" {
  type    = string
  default = "ocpadmin"
}


variable "openshift_version" {
  type = string
}

variable "harbor_version" {
  type    = string
  default = "2.2.3"
}

variable "compose_version" {
  type    = string
  default = "1.29.2"
}

variable "cloudctl_version" {
  type    = string
  default = "latest"
}

variable "openshift_pull_secret" {
  type = string
}

variable "openshift_product_repo" {
  type    = string
  default = "openshift-release-dev"
}

variable "openshift_release_name" {
  type    = string
  default = "ocp-release"
}

variable "openshift_architecture" {
  type    = string
  default = "x86_64"
}

variable "openshift_mirror_olm" {
  type    = bool
  default = true
}

variable "openshift_mirror_platform" {
  type    = bool
  default = true
}

variable "entitlement_key" {
  type = string
}

variable "case_name" {
  type = string
}

variable "case_version" {
  type = string
}

variable "case_inventory_setup" {
  type = string
}

variable "case_repo_path" {
  type = string
}

variable "certificate_country" {
  type    = string
  default = "US"
}

variable "certificate_state" {
  type    = string
  default = "North Carolina"
}

variable "certificate_locality" {
  type    = string
  default = "Raleigh"
}

variable "certificate_organization" {
  type    = string
  default = "IBM Go To Market"
}

variable "certificate_commonname" {
  type    = string
  default = "registry.example.com"
}

variable "extra_disk_mountpoint" {
  type    = string
  default = "/data"
}

variable "disk_device" {
  type = string
}

variable "volume_name" {
  type    = string
  default = "data"
}

variable "extra_registries" {
  type = map(any)
  default = {
    "registry.example.com" : {
      "username" : "",
      "password" : "",
      "namespace" : "",
      "src_image" : "",
      "dst_image" : "",
    }
  }
}

variable "registry_namespaces" {
  type = list(string)
  default = [
    "ocp4",
    "olm",
    "cp",
    "cpopen",
    "opencloudio",
    "ibmcom"
  ]
}

variable "keep_operators" {
  type = list(string)
  default = [
    "ocs-operator",
    "openshift-gitops-operator",
    "openshift-pipelines-operator-rh",
    "local-storage-operator"
  ]
}

variable "preexisting_cluster_resource_group_name" {
  type = string
}

variable "openshift_base_domain" {
  type = string
}

variable "openshift_cluster_name" {
  type = string
}

variable "azure_dns_resource_group_name" {
  type = string
}

variable "preexisting_network_resource_group_name" {
  type = string
}

variable "preexisting_virtual_network_name" {
  type = string
}

variable "preexisting_control_plane_subnet" {
  type = string
}

variable "preexisting_compute_subnet" {
  type = string
}

variable "openshift_worker_vm_type" {
  type    = string
  default = "Standard_D4s_v3"
}

variable "openshift_worker_os_disk_size" {
  type    = string
  default = "512"
}

variable "openshift_worker_node_count" {
  type    = string
  default = "3"
}

variable "openshift_master_vm_type" {
  type    = string
  default = "Standard_D4s_v3"
}

variable "openshift_master_os_disk_size" {
  type    = string
  default = "1024"
}

variable "openshift_cluster_network_cidr" {
  type    = string
  default = "10.128.0.0/14"
}

variable "openshift_cluster_network_host_prefix" {
  type    = string
  default = "23"
}

variable "openshift_machine_cidr" {
  type    = string
  default = "10.10.0.0/16"
}

variable "openshift_service_network_cidr" {
  type    = string
  default = "172.30.0.0/16"
}

variable "azure_outbound_type" {
  type    = string
  default = "UserDefinedRouting"
}

variable "openshift_azure_private" {
  type    = string
  default = true
}

variable "openshift_network_type" {
  type    = string
  default = "OpenShiftSDN"
}

variable "playbook_path" {
  type    = string
  default = "../../ansible/playbook"
  validation {
    condition     = regex("/playbook$", var.playbook_path) == "/playbook"
    error_message = "Folder for ansible playbooks must be called playbooks (/path/to/playbook)."
  }
}

variable "inventory_path" {
  type    = string
  default = "../common/inventory"
}
