variable "bastion_host_public" {
  type = string
}

variable "username" {
  type = string
}

variable "private_ssh_key" {
  type = string
}

variable "playbook" {
  type = string
}

variable "playbook_path" {
  type = string
}

variable "inventory" {
  type = string
}

variable "playbook_workspace" {
  type    = string
  default = ""
}

variable "upload_files" {
  type    = string
  default = ""
}
