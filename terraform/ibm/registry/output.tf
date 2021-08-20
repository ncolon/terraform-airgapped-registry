output "private_ip" {
  value = ibm_is_instance.registry.primary_network_interface[0].primary_ipv4_address
}

output "vm_id" {
  value = ibm_is_instance.registry.id
}
