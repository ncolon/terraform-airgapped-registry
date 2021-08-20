resource "ibm_resource_instance" "kms_instance" {
  name              = "${var.prefix}-kms"
  resource_group_id = var.resource_group_id
  service           = "kms"
  plan              = "tiered-pricing"
  location          = var.region
}

resource "ibm_iam_authorization_policy" "policy" {
  source_service_name      = "server-protect"
  target_service_name      = "kms"
  target_resource_group_id = var.resource_group_id
  roles                    = ["Reader"]
}

resource "ibm_kp_key" "key_protect" {
  key_protect_id = ibm_resource_instance.kms_instance.guid
  key_name       = "${var.prefix}-key-protect"
  standard_key   = false
}
