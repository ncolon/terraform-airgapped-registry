resource "ibm_is_snapshot" "data_snapshot" {
  name          = "data-snapshot"
  source_volume = var.source_disk_id
}

resource "ibm_is_instance_volume_attachment" "data_attachment" {
  instance = var.target_vm_id

  name                               = "data-attachment"
  profile                            = "general-purpose"
  snapshot                           = ibm_is_snapshot.data_snapshot.id
  delete_volume_on_attachment_delete = true
  delete_volume_on_instance_delete   = true
  volume_name                        = "registry-data-disk"
  encryption_key                     = var.encryption_key
  capacity                           = var.data_disk_size
}
