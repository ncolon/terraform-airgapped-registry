output "bastion_public_ip" {
  value = module.bastion.public_ip
}

output "bastion_private_ip" {
  value = module.bastion.private_ip
}

output "registry_private_ip" {
  value = module.registry.private_ip
}

output "registry_password" {
  sensitive = true
  value     = random_password.registry_password.result
}

output "resource_group" {
  value = local.resource_group
}
