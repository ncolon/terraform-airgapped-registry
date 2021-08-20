variable "region" {
  type        = string
  description = "The target Azure region for the image registry."
}

variable "resource_group" {
  type = string
}

variable "vnet_cidr" {
  type = string
}

variable "prefix" {
  type = string
}
