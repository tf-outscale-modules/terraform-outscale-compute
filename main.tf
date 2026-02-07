########################################
# Security Groups
########################################

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

########################################
# Keypair
########################################

resource "outscale_keypair" "this" {
  count = var.enable_keypair ? 1 : 0

  keypair_name = var.keypair_name != null ? var.keypair_name : "${var.project_name}-${var.environment}-keypair"
  public_key   = var.keypair_public_key
}

########################################
# VMs
########################################

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

########################################
# Volumes
########################################

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

########################################
# Public IPs
########################################

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
