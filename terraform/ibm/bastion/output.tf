output "private_ip" {
  value = ibm_is_instance.bastion.primary_network_interface[0].primary_ipv4_address
}

output "public_ip" {
  value = ibm_is_floating_ip.bastion_public.address
}

output "data_disk_id" {
  value = ibm_is_instance_volume_attachment.data_attachment.volume
}
