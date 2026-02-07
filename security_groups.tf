resource "outscale_security_group" "this" {
  for_each = var.enable_security_groups ? var.security_groups : {}

  description         = each.value.description
  security_group_name = "${var.project_name}-${var.environment}-${each.key}"
  net_id              = each.value.net_id

  dynamic "tags" {
    for_each = merge(
      local.common_tags,
      {
        Name = "${var.project_name}-${var.environment}-${each.key}"
      },
      each.value.tags,
    )
    content {
      key   = tags.key
      value = tags.value
    }
  }
}

resource "outscale_security_group_rule" "this" {
  for_each = local.sg_all_rules

  flow              = each.value.flow
  security_group_id = outscale_security_group.this[each.value.sg_key].security_group_id
  from_port_range   = each.value.from_port_range
  to_port_range     = each.value.to_port_range
  ip_protocol       = each.value.ip_protocol
  ip_range          = each.value.ip_range

  security_group_account_id_to_link = each.value.security_group_account_id_to_link
  security_group_name_to_link       = each.value.security_group_name_to_link
}
