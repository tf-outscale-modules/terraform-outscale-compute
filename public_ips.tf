resource "outscale_public_ip" "this" {
  for_each = local.vm_public_ip_instances

  dynamic "tags" {
    for_each = merge(
      local.common_tags,
      {
        Name = "${each.value.name}-pip"
      },
    )
    content {
      key   = tags.key
      value = tags.value
    }
  }
}

resource "outscale_public_ip_link" "this" {
  for_each = local.vm_public_ip_instances

  public_ip_id = outscale_public_ip.this[each.key].public_ip_id
  vm_id        = outscale_vm.this[each.key].vm_id
}
