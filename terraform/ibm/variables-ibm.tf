variable "ibmcloud_api_key" {
  type        = string
  description = "IBM Cloud API Key"
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

variable "preexisting_virtual_network_name" {
  type = string
}

variable "preexisting_roks_cluster_name" {
  type = string
}

variable "ibmcloud_version" {
  type = string
}
