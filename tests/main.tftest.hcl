# Test: Single VM creation
run "single_vm" {
  command = plan

  variables {
    project_name = "testproject"
    environment  = "dev"
    vms = {
      web = {
        count     = 1
        image_id  = "ami-12345678"
        vm_type   = "tinav5.c1r1p1"
        subnet_id = "subnet-12345678"
      }
    }
  }

  assert {
    condition     = length(outscale_vm.this) == 1
    error_message = "Expected exactly 1 VM to be created"
  }

  assert {
    condition     = outscale_vm.this["web-0"].image_id == "ami-12345678"
    error_message = "VM image_id mismatch"
  }

  assert {
    condition     = outscale_vm.this["web-0"].vm_type == "tinav5.c1r1p1"
    error_message = "VM type mismatch"
  }
}

# Test: Multi-role VM counts
run "multi_role_vms" {
  command = plan

  variables {
    project_name = "testproject"
    environment  = "prod"
    vms = {
      frontend = {
        count     = 3
        image_id  = "ami-12345678"
        vm_type   = "tinav5.c2r4p1"
        subnet_id = "subnet-11111111"
      }
      backend = {
        count     = 2
        image_id  = "ami-87654321"
        vm_type   = "tinav5.c4r8p1"
        subnet_id = "subnet-22222222"
      }
    }
  }

  assert {
    condition     = length(outscale_vm.this) == 5
    error_message = "Expected 5 VMs total (3 frontend + 2 backend)"
  }

  assert {
    condition     = outscale_vm.this["frontend-0"].image_id == "ami-12345678"
    error_message = "Frontend VM image_id mismatch"
  }

  assert {
    condition     = outscale_vm.this["backend-1"].image_id == "ami-87654321"
    error_message = "Backend VM image_id mismatch"
  }
}

# Test: Public IP conditional creation
run "public_ip_creation" {
  command = plan

  variables {
    project_name = "testproject"
    environment  = "dev"
    vms = {
      web = {
        count            = 2
        image_id         = "ami-12345678"
        vm_type          = "tinav5.c1r1p1"
        subnet_id        = "subnet-12345678"
        enable_public_ip = true
      }
      worker = {
        count     = 1
        image_id  = "ami-12345678"
        vm_type   = "tinav5.c1r1p1"
        subnet_id = "subnet-12345678"
      }
    }
  }

  assert {
    condition     = length(outscale_public_ip.this) == 2
    error_message = "Expected 2 public IPs (only for web VMs)"
  }

  assert {
    condition     = length(outscale_public_ip_link.this) == 2
    error_message = "Expected 2 public IP links"
  }
}

# Test: Security group conditional creation
run "security_groups_disabled" {
  command = plan

  variables {
    project_name           = "testproject"
    environment            = "dev"
    enable_security_groups = false
    vms = {
      web = {
        count     = 1
        image_id  = "ami-12345678"
        vm_type   = "tinav5.c1r1p1"
        subnet_id = "subnet-12345678"
      }
    }
  }

  assert {
    condition     = length(outscale_security_group.this) == 0
    error_message = "Expected no security groups when disabled"
  }
}

run "security_groups_enabled" {
  command = plan

  variables {
    project_name           = "testproject"
    environment            = "dev"
    enable_security_groups = true
    security_groups = {
      web = {
        description = "Web security group"
        net_id      = "net-12345678"
        inbound_rules = [
          {
            from_port_range = 80
            to_port_range   = 80
            ip_protocol     = "tcp"
            ip_range        = "0.0.0.0/0"
          },
        ]
        outbound_rules = [
          {
            from_port_range = 0
            to_port_range   = 0
            ip_protocol     = "-1"
            ip_range        = "0.0.0.0/0"
          },
        ]
      }
    }
    vms = {
      app = {
        count               = 1
        image_id            = "ami-12345678"
        vm_type             = "tinav5.c1r1p1"
        subnet_id           = "subnet-12345678"
        security_group_keys = ["web"]
      }
    }
  }

  assert {
    condition     = length(outscale_security_group.this) == 1
    error_message = "Expected 1 security group"
  }

  assert {
    condition     = length(outscale_security_group_rule.this) == 2
    error_message = "Expected 2 security group rules (1 inbound + 1 outbound)"
  }
}

# Test: Volume creation per VM
run "volume_creation" {
  command = plan

  variables {
    project_name = "testproject"
    environment  = "dev"
    vms = {
      db = {
        count                    = 2
        image_id                 = "ami-12345678"
        vm_type                  = "tinav5.c4r8p1"
        subnet_id                = "subnet-12345678"
        placement_subregion_name = "eu-west-2a"
        volumes = {
          data = {
            size        = 100
            type        = "io1"
            iops        = 3000
            device_name = "/dev/xvdb"
          }
          logs = {
            size        = 50
            device_name = "/dev/xvdc"
          }
        }
      }
    }
  }

  assert {
    condition     = length(outscale_volume.this) == 4
    error_message = "Expected 4 volumes (2 VMs x 2 volumes each)"
  }

  assert {
    condition     = length(outscale_volume_link.this) == 4
    error_message = "Expected 4 volume links"
  }

  assert {
    condition     = outscale_volume.this["db-0:data"].size == 100
    error_message = "Volume size mismatch for db-0:data"
  }

  assert {
    condition     = outscale_volume.this["db-1:logs"].size == 50
    error_message = "Volume size mismatch for db-1:logs"
  }
}

# Test: Naming convention
run "naming_convention" {
  command = plan

  variables {
    project_name = "myapp"
    environment  = "staging"
    vms = {
      api = {
        count     = 1
        image_id  = "ami-12345678"
        vm_type   = "tinav5.c1r1p1"
        subnet_id = "subnet-12345678"
      }
    }
  }

  assert {
    condition     = local.vm_instances["api-0"].name == "myapp-staging-api-0"
    error_message = "VM name should follow {project}-{env}-{role}-{index} pattern"
  }
}

# Test: Keypair creation
run "keypair_disabled" {
  command = plan

  variables {
    project_name   = "testproject"
    environment    = "dev"
    enable_keypair = false
    vms = {
      web = {
        count     = 1
        image_id  = "ami-12345678"
        vm_type   = "tinav5.c1r1p1"
        subnet_id = "subnet-12345678"
      }
    }
  }

  assert {
    condition     = length(outscale_keypair.this) == 0
    error_message = "Expected no keypair when disabled"
  }
}

run "keypair_enabled" {
  command = plan

  variables {
    project_name       = "testproject"
    environment        = "dev"
    enable_keypair     = true
    keypair_name       = "test-keypair"
    keypair_public_key = "ssh-rsa AAAA... test@example.com"
    vms = {
      web = {
        count     = 1
        image_id  = "ami-12345678"
        vm_type   = "tinav5.c1r1p1"
        subnet_id = "subnet-12345678"
      }
    }
  }

  assert {
    condition     = length(outscale_keypair.this) == 1
    error_message = "Expected 1 keypair when enabled"
  }

  assert {
    condition     = outscale_keypair.this[0].keypair_name == "test-keypair"
    error_message = "Keypair name mismatch"
  }
}

# Test: Environment validation rejects invalid values
run "invalid_environment" {
  command = plan

  variables {
    project_name = "testproject"
    environment  = "invalid"
    vms = {
      web = {
        count     = 1
        image_id  = "ami-12345678"
        vm_type   = "tinav5.c1r1p1"
        subnet_id = "subnet-12345678"
      }
    }
  }

  expect_failures = [
    var.environment,
  ]
}

# Test: Project name validation rejects invalid values
run "invalid_project_name" {
  command = plan

  variables {
    project_name = "Invalid_Name!"
    environment  = "dev"
    vms = {
      web = {
        count     = 1
        image_id  = "ami-12345678"
        vm_type   = "tinav5.c1r1p1"
        subnet_id = "subnet-12345678"
      }
    }
  }

  expect_failures = [
    var.project_name,
  ]
}

# Test: VM count validation rejects zero
run "invalid_vm_count" {
  command = plan

  variables {
    project_name = "testproject"
    environment  = "dev"
    vms = {
      web = {
        count     = 0
        image_id  = "ami-12345678"
        vm_type   = "tinav5.c1r1p1"
        subnet_id = "subnet-12345678"
      }
    }
  }

  expect_failures = [
    var.vms,
  ]
}

# Test: Common tags propagation
run "tags_propagation" {
  command = plan

  variables {
    project_name = "myapp"
    environment  = "prod"
    tags = {
      Team = "platform"
    }
    vms = {
      api = {
        count     = 1
        image_id  = "ami-12345678"
        vm_type   = "tinav5.c1r1p1"
        subnet_id = "subnet-12345678"
        tags = {
          Tier = "api"
        }
      }
    }
  }

  assert {
    condition     = local.vm_instances["api-0"].tags["Project"] == "myapp"
    error_message = "Project tag not propagated"
  }

  assert {
    condition     = local.vm_instances["api-0"].tags["Environment"] == "prod"
    error_message = "Environment tag not propagated"
  }

  assert {
    condition     = local.vm_instances["api-0"].tags["ManagedBy"] == "terraform"
    error_message = "ManagedBy tag not propagated"
  }

  assert {
    condition     = local.vm_instances["api-0"].tags["Team"] == "platform"
    error_message = "Custom tag not propagated"
  }

  assert {
    condition     = local.vm_instances["api-0"].tags["Role"] == "api"
    error_message = "Role tag not set"
  }

  assert {
    condition     = local.vm_instances["api-0"].tags["Tier"] == "api"
    error_message = "Role-specific tag not propagated"
  }
}

# Test: Block device mappings
run "block_device_mappings" {
  command = plan

  variables {
    project_name = "testproject"
    environment  = "dev"
    vms = {
      web = {
        count     = 1
        image_id  = "ami-12345678"
        vm_type   = "tinav5.c2r4p1"
        subnet_id = "subnet-12345678"
        block_device_mappings = [
          {
            device_name = "/dev/sda1"
            bsu = {
              volume_size           = 50
              volume_type           = "gp2"
              delete_on_vm_deletion = true
            }
          },
        ]
      }
    }
  }

  assert {
    condition     = length(outscale_vm.this) == 1
    error_message = "Expected 1 VM with block device mappings"
  }
}

# Test: Flexible GPUs disabled by default
run "flexible_gpus_disabled" {
  command = plan

  variables {
    project_name = "testproject"
    environment  = "dev"
    vms = {
      web = {
        count     = 1
        image_id  = "ami-12345678"
        vm_type   = "tinav5.c1r1p1"
        subnet_id = "subnet-12345678"
      }
    }
  }

  assert {
    condition     = length(outscale_flexible_gpu.this) == 0
    error_message = "Expected no flexible GPUs when disabled"
  }
}

# Test: Flexible GPUs enabled with role targeting
run "flexible_gpus_enabled" {
  command = plan

  variables {
    project_name         = "testproject"
    environment          = "dev"
    enable_flexible_gpus = true
    flexible_gpus = {
      compute = {
        model_name            = "nvidia-p100"
        generation            = "v5"
        delete_on_vm_deletion = true
        vm_role               = "backend"
      }
    }
    vms = {
      backend = {
        count                    = 2
        image_id                 = "ami-12345678"
        vm_type                  = "tinav5.c4r8p1"
        subnet_id                = "subnet-12345678"
        placement_subregion_name = "eu-west-2a"
      }
      frontend = {
        count     = 1
        image_id  = "ami-12345678"
        vm_type   = "tinav5.c1r1p1"
        subnet_id = "subnet-12345678"
      }
    }
  }

  assert {
    condition     = length(outscale_flexible_gpu.this) == 2
    error_message = "Expected 2 flexible GPUs (1 per backend VM)"
  }

  assert {
    condition     = length(outscale_flexible_gpu_link.this) == 2
    error_message = "Expected 2 flexible GPU links (1 per backend VM)"
  }

  assert {
    condition     = outscale_flexible_gpu.this["compute:backend-0"].model_name == "nvidia-p100"
    error_message = "GPU model_name mismatch"
  }
}

# Test: Multiple GPU models targeting same role
run "flexible_gpus_multi_model" {
  command = plan

  variables {
    project_name         = "testproject"
    environment          = "dev"
    enable_flexible_gpus = true
    flexible_gpus = {
      compute = {
        model_name            = "nvidia-p100"
        generation            = "v5"
        delete_on_vm_deletion = true
        vm_role               = "gpu"
      }
      render = {
        model_name            = "nvidia-p100"
        generation            = "v5"
        delete_on_vm_deletion = true
        vm_role               = "gpu"
      }
    }
    vms = {
      gpu = {
        count                    = 1
        image_id                 = "ami-12345678"
        vm_type                  = "tinav5.c4r8p1"
        subnet_id                = "subnet-12345678"
        placement_subregion_name = "eu-west-2a"
      }
    }
  }

  assert {
    condition     = length(outscale_flexible_gpu.this) == 2
    error_message = "Expected 2 flexible GPUs (2 configs x 1 VM)"
  }

  assert {
    condition     = length(outscale_flexible_gpu_link.this) == 1
    error_message = "Expected 1 flexible GPU link (1 VM with 2 GPUs)"
  }
}

# Test: Flexible GPU validation rejects invalid vm_role
run "flexible_gpus_invalid_role" {
  command = plan

  variables {
    project_name         = "testproject"
    environment          = "dev"
    enable_flexible_gpus = true
    flexible_gpus = {
      compute = {
        model_name = "nvidia-p100"
        vm_role    = "nonexistent"
      }
    }
    vms = {
      web = {
        count     = 1
        image_id  = "ami-12345678"
        vm_type   = "tinav5.c1r1p1"
        subnet_id = "subnet-12345678"
      }
    }
  }

  expect_failures = [
    var.flexible_gpus,
  ]
}

# Test: Deletion protection flag
run "deletion_protection" {
  command = plan

  variables {
    project_name = "testproject"
    environment  = "prod"
    vms = {
      db = {
        count               = 1
        image_id            = "ami-12345678"
        vm_type             = "tinav5.c4r8p1"
        subnet_id           = "subnet-12345678"
        deletion_protection = true
      }
    }
  }

  assert {
    condition     = outscale_vm.this["db-0"].deletion_protection == true
    error_message = "Deletion protection should be enabled"
  }
}
