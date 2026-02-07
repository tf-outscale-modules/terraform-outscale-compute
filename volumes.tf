resource "outscale_volume" "this" {
  for_each = local.volume_instances

  size           = each.value.size
  volume_type    = each.value.type
  iops           = each.value.iops
  snapshot_id    = each.value.snapshot_id
  subregion_name = each.value.subregion_name

  dynamic "tags" {
    for_each = each.value.tags
    content {
      key   = tags.key
      value = tags.value
    }
  }
}

resource "outscale_volume_link" "this" {
  for_each = local.volume_instances

  volume_id   = outscale_volume.this[each.key].volume_id
  vm_id       = outscale_vm.this[each.value.vm_key].vm_id
  device_name = each.value.device_name
}
