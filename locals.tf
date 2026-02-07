locals {
  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    },
    var.tags,
  )

  # Flatten role-based VM map into individual instances
  # { "frontend-0" => {...}, "frontend-1" => {...}, "backend-0" => {...} }
  vm_instances = merge([
    for role, cfg in var.vms : {
      for i in range(cfg.count) : "${role}-${i}" => {
        role                     = role
        index                    = i
        name                     = "${var.project_name}-${var.environment}-${role}-${i}"
        image_id                 = cfg.image_id
        vm_type                  = cfg.vm_type
        subnet_id                = cfg.subnet_id
        keypair_name             = cfg.keypair_name
        security_group_ids       = cfg.security_group_ids
        security_group_keys      = cfg.security_group_keys
        placement_subregion_name = cfg.placement_subregion_name
        enable_public_ip         = cfg.enable_public_ip
        deletion_protection      = cfg.deletion_protection
        user_data                = cfg.user_data
        block_device_mappings    = cfg.block_device_mappings
        tags = merge(
          local.common_tags,
          {
            Name = "${var.project_name}-${var.environment}-${role}-${i}"
            Role = role
          },
          cfg.tags,
        )
      }
    }
  ]...)

  # Flatten volumes: { "backend-0:data" => {...}, "backend-1:data" => {...} }
  volume_instances = merge([
    for vm_key, vm in local.vm_instances : {
      for vol_key, vol in var.vms[vm.role].volumes : "${vm_key}:${vol_key}" => {
        vm_key         = vm_key
        vol_key        = vol_key
        name           = "${vm.name}-${vol_key}"
        size           = vol.size
        type           = vol.type
        iops           = vol.iops
        snapshot_id    = vol.snapshot_id
        device_name    = vol.device_name
        subregion_name = coalesce(vol.subregion_name, vm.placement_subregion_name)
        tags = merge(
          local.common_tags,
          {
            Name = "${vm.name}-${vol_key}"
            Role = vm.role
          },
          vol.tags,
        )
      }
    }
  ]...)

  # Flatten security group inbound rules
  sg_inbound_rules = merge([
    for sg_key, sg in var.security_groups : {
      for idx, rule in sg.inbound_rules : "${sg_key}:inbound:${idx}" => {
        sg_key                            = sg_key
        flow                              = "Inbound"
        from_port_range                   = rule.from_port_range
        to_port_range                     = rule.to_port_range
        ip_protocol                       = rule.ip_protocol
        ip_range                          = rule.ip_range
        security_group_account_id_to_link = rule.security_group_account_id_to_link
        security_group_name_to_link       = rule.security_group_name_to_link
      }
    }
  ]...)

  # Flatten security group outbound rules
  sg_outbound_rules = merge([
    for sg_key, sg in var.security_groups : {
      for idx, rule in sg.outbound_rules : "${sg_key}:outbound:${idx}" => {
        sg_key                            = sg_key
        flow                              = "Outbound"
        from_port_range                   = rule.from_port_range
        to_port_range                     = rule.to_port_range
        ip_protocol                       = rule.ip_protocol
        ip_range                          = rule.ip_range
        security_group_account_id_to_link = rule.security_group_account_id_to_link
        security_group_name_to_link       = rule.security_group_name_to_link
      }
    }
  ]...)

  sg_all_rules = var.enable_security_groups ? merge(local.sg_inbound_rules, local.sg_outbound_rules) : {}

  # Filter VMs that need public IPs
  vm_public_ip_instances = {
    for vm_key, vm in local.vm_instances : vm_key => vm
    if vm.enable_public_ip
  }
}
