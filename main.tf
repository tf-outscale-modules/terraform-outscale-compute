resource "outscale_vm" "this" {
  for_each = local.vm_instances

  image_id                 = each.value.image_id
  vm_type                  = each.value.vm_type
  subnet_id                = each.value.subnet_id
  keypair_name             = each.value.keypair_name
  placement_subregion_name = each.value.placement_subregion_name
  deletion_protection      = each.value.deletion_protection
  user_data                = each.value.user_data

  security_group_ids = concat(
    each.value.security_group_ids,
    [for key in each.value.security_group_keys : outscale_security_group.this[key].security_group_id],
  )

  dynamic "block_device_mappings" {
    for_each = each.value.block_device_mappings
    content {
      device_name = block_device_mappings.value.device_name
      bsu {
        volume_size           = block_device_mappings.value.bsu.volume_size
        volume_type           = block_device_mappings.value.bsu.volume_type
        iops                  = block_device_mappings.value.bsu.iops
        snapshot_id           = block_device_mappings.value.bsu.snapshot_id
        delete_on_vm_deletion = block_device_mappings.value.bsu.delete_on_vm_deletion
      }
    }
  }

  tags {
    key   = "Name"
    value = each.value.name
  }

  dynamic "tags" {
    for_each = each.value.tags
    content {
      key   = tags.key
      value = tags.value
    }
  }
}
