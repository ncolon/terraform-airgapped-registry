resource "aws_vpc" "new_vpc" {
  count = 1

  cidr_block           = var.cidr_blocks[0]
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    {
      "Name" = "${var.cluster_id}-vpc"
    },
    var.tags,
  )
}
