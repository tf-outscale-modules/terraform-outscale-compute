provider "outscale" {
  region = "eu-west-2"
}

# Networking (external module)
module "networking" {
  source = "github.com/tf-outscale-modules/terraform-outscale-networking?ref=v1.0.0"

  project_name = "myproject"
  environment  = "prod"

  net_cidr_block = "10.0.0.0/16"
  subnets = {
    frontend = {
      cidr_block     = "10.0.1.0/24"
      subregion_name = "eu-west-2a"
    }
    backend = {
      cidr_block     = "10.0.2.0/24"
      subregion_name = "eu-west-2a"
    }
  }
}

# Compute module with all features
module "compute" {
  source = "../.."

  project_name = "myproject"
  environment  = "prod"

  tags = {
    Team  = "platform"
    Owner = "infra@example.com"
  }

  # Keypair
  enable_keypair     = true
  keypair_name       = "myproject-prod-keypair"
  keypair_public_key = var.ssh_public_key

  # Security groups
  enable_security_groups = true
  security_groups = {
    frontend = {
      description = "Frontend security group - HTTP/HTTPS"
      net_id      = module.networking.net_id
      inbound_rules = [
        {
          from_port_range = 80
          to_port_range   = 80
          ip_protocol     = "tcp"
          ip_range        = "0.0.0.0/0"
        },
        {
          from_port_range = 443
          to_port_range   = 443
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
    backend = {
      description = "Backend security group - app traffic"
      net_id      = module.networking.net_id
      inbound_rules = [
        {
          from_port_range = 8080
          to_port_range   = 8080
          ip_protocol     = "tcp"
          ip_range        = "10.0.1.0/24"
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

  # VMs
  vms = {
    frontend = {
      count                    = 3
      image_id                 = "ami-12345678"
      vm_type                  = "tinav5.c2r4p1"
      subnet_id                = module.networking.subnet_ids["frontend"]
      keypair_name             = "myproject-prod-keypair"
      security_group_keys      = ["frontend"]
      placement_subregion_name = "eu-west-2a"
      enable_public_ip         = true
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
      tags = {
        Tier = "frontend"
      }
    }
    backend = {
      count                    = 2
      image_id                 = "ami-12345678"
      vm_type                  = "tinav5.c4r8p1"
      subnet_id                = module.networking.subnet_ids["backend"]
      keypair_name             = "myproject-prod-keypair"
      security_group_keys      = ["backend"]
      placement_subregion_name = "eu-west-2a"
      block_device_mappings = [
        {
          device_name = "/dev/sda1"
          bsu = {
            volume_size           = 100
            volume_type           = "gp2"
            delete_on_vm_deletion = true
          }
        },
      ]
      volumes = {
        data = {
          size        = 200
          type        = "io1"
          iops        = 3000
          device_name = "/dev/xvdb"
          tags = {
            Purpose = "application-data"
          }
        }
        logs = {
          size        = 50
          type        = "gp2"
          device_name = "/dev/xvdc"
          tags = {
            Purpose = "application-logs"
          }
        }
      }
      tags = {
        Tier = "backend"
      }
    }
  }
}
