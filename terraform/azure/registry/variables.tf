variable "prefix" {
  type = string
}

variable "region" {
  type = string
}

variable "resource_group" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "vm_size" {
  type = string
}

variable "username" {
  type = string
}

variable "public_ssh_key" {
  type = string
}

variable "private_ssh_key" {
  type    = string
  default = ""
}

variable "encryption_set_id" {
  type = string
}
