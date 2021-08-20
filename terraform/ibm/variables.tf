variable "cloud_platform" {
  type = string
}

variable "region" {
  type        = string
  description = "The target IBM Cloud region for the image registry."
}

variable "prefix" {
  type = string
}

variable "registry_vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "bastion_vm_size" {
  type = string
}

variable "registry_vm_size" {
  type = string
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
  type = string
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
