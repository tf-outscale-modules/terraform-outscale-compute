# Outscale Compute Terraform Module

[![Apache 2.0][apache-shield]][apache]
[![Terraform][terraform-badge]][terraform-url]
[![Outscale Provider][provider-badge]][provider-url]
[![Latest Release][release-badge]][release-url]

Terraform module for provisioning and managing Outscale cloud virtual machines with role-based definitions, security groups, volumes, public IPs, and SSH keypairs.

## Features

- **Role-based VM map** — define roles (e.g., `frontend`, `backend`) with counts; the module flattens them into individual instances with stable `for_each` keys
- **Security groups** — optionally create security groups with inbound/outbound rules, referenced by key from VM definitions
- **Block storage volumes** — attach additional volumes per VM role with automatic subregion derivation
- **Public IPs** — per-role toggle for elastic IP allocation and association
- **SSH keypair** — optional keypair creation with sensitive public key handling
- **Consistent naming** — all resources follow `{project}-{environment}-{role}-{index}` pattern
- **Flexible tagging** — common tags merged with role-specific and resource-specific tags

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5 |
| outscale | ~> 1.0 |

## Usage

### Basic Example

```hcl
module "compute" {
  source = "git::https://gitlab.com/leminnov/terraform/modules/outscale-compute.git?ref=v0.1.0"

  project_name = "myproject"
  environment  = "dev"

  vms = {
    web = {
      count      = 1
      image_id   = "ami-12345678"
      vm_type    = "tinav5.c1r1p1"
      subnet_id  = "subnet-12345678"
    }
  }
}
```

### Complete Example

```hcl
module "compute" {
  source = "git::https://gitlab.com/leminnov/terraform/modules/outscale-compute.git?ref=v0.1.0"

  project_name = "myproject"
  environment  = "prod"

  tags = {
    Team  = "platform"
    Owner = "infra@example.com"
  }

  enable_keypair     = true
  keypair_name       = "myproject-prod-keypair"
  keypair_public_key = var.ssh_public_key

  enable_security_groups = true
  security_groups = {
    web = {
      description = "Web traffic"
      net_id      = module.networking.net_id
      inbound_rules = [
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
  }

  vms = {
    frontend = {
      count                    = 3
      image_id                 = "ami-12345678"
      vm_type                  = "tinav5.c2r4p1"
      subnet_id                = module.networking.subnet_ids["frontend"]
      keypair_name             = "myproject-prod-keypair"
      security_group_keys      = ["web"]
      placement_subregion_name = "eu-west-2a"
      enable_public_ip         = true
    }
    backend = {
      count                    = 2
      image_id                 = "ami-12345678"
      vm_type                  = "tinav5.c4r8p1"
      subnet_id                = module.networking.subnet_ids["backend"]
      keypair_name             = "myproject-prod-keypair"
      placement_subregion_name = "eu-west-2a"
      volumes = {
        data = {
          size        = 200
          type        = "io1"
          iops        = 3000
          device_name = "/dev/xvdb"
        }
      }
    }
  }
}
```

### Conditional Creation

```hcl
# Security groups are only created when explicitly enabled
enable_security_groups = true   # default: false

# Keypair is only created when explicitly enabled
enable_keypair = true           # default: false

# Public IPs are per-role
vms = {
  public_role  = { enable_public_ip = true,  ... }
  private_role = { enable_public_ip = false, ... }  # default
}
```

## Security Considerations

1. SSH keypair public keys are marked as `sensitive` — provide via `TF_VAR_keypair_public_key` or encrypted tfvars
2. Security groups default to no rules — you must explicitly define inbound/outbound rules
3. State files contain sensitive data — always use encrypted remote backends
4. Never use `0.0.0.0/0` for SSH access in production security group rules

See [SECURITY.md](SECURITY.md) for detailed security guidance.

## Known Limitations

1. The Outscale provider does not support `deletion_protection` as a first-class attribute on all resource types
2. Volume IOPS configuration is only effective for `io1` volume types
3. Security group rules with multiple IP ranges require separate rule entries
4. Public IP association requires the VM to be in a running state

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## Documentation

| Document | Description |
|----------|-------------|
| [README.md](README.md) | Module overview and usage |
| [SECURITY.md](SECURITY.md) | Security considerations and best practices |
| [TESTING.md](TESTING.md) | Test execution and CI integration |
| [CHANGELOG.md](CHANGELOG.md) | Version history and release notes |

## Contributing

1. Create a feature branch from `develop`
2. Make your changes following the existing code style
3. Ensure all pre-commit hooks pass: `pre-commit run -a`
4. Run validation: `terraform fmt -check -recursive && terraform validate`
5. Submit a merge request

## License

This project is licensed under the Apache License 2.0 — see the [LICENSE](LICENSE) file for details.

## Disclaimer

This module is provided "as is", without warranty of any kind, express or implied. Use at your own risk.

[apache]: https://opensource.org/licenses/Apache-2.0
[apache-shield]: https://img.shields.io/badge/License-Apache%202.0-blue.svg

[terraform-badge]: https://img.shields.io/badge/Terraform-%3E%3D1.5-623CE4
[terraform-url]: https://www.terraform.io

[provider-badge]: https://img.shields.io/badge/Outscale%20Provider-~%3E1.0-blueviolet
[provider-url]: https://registry.terraform.io/providers/outscale/outscale/latest

[release-badge]: https://img.shields.io/gitlab/v/release/leminnov/terraform/modules/outscale-compute?include_prereleases&sort=semver
[release-url]: https://gitlab.com/leminnov/terraform/modules/outscale-compute/-/releases
