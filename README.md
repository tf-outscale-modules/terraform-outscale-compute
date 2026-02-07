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
- **Flexible GPUs** — allocate and attach Outscale fGPUs to VMs by role, with auto-distribution across instances
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
      count     = 1
      image_id  = "ami-12345678"
      vm_type   = "tinav5.c1r1p1"
      subnet_id = "subnet-12345678"
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

### Flexible GPUs

```hcl
# Attach one nvidia-p100 GPU to each backend VM
enable_flexible_gpus = true
flexible_gpus = {
  compute = {
    model_name            = "nvidia-p100"
    generation            = "v5"
    delete_on_vm_deletion = true
    vm_role               = "backend"  # must match a key in vms
  }
}
```

> **Note:** Attaching/detaching GPUs stops and restarts the VM. Max 2 identical GPU models per VM.

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
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_outscale"></a> [outscale](#requirement\_outscale) | ~> 1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_outscale"></a> [outscale](#provider\_outscale) | 1.3.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [outscale_keypair.this](https://registry.terraform.io/providers/outscale/outscale/latest/docs/resources/keypair) | resource |
| [outscale_public_ip.this](https://registry.terraform.io/providers/outscale/outscale/latest/docs/resources/public_ip) | resource |
| [outscale_public_ip_link.this](https://registry.terraform.io/providers/outscale/outscale/latest/docs/resources/public_ip_link) | resource |
| [outscale_security_group.this](https://registry.terraform.io/providers/outscale/outscale/latest/docs/resources/security_group) | resource |
| [outscale_security_group_rule.this](https://registry.terraform.io/providers/outscale/outscale/latest/docs/resources/security_group_rule) | resource |
| [outscale_vm.this](https://registry.terraform.io/providers/outscale/outscale/latest/docs/resources/vm) | resource |
| [outscale_volume.this](https://registry.terraform.io/providers/outscale/outscale/latest/docs/resources/volume) | resource |
| [outscale_volume_link.this](https://registry.terraform.io/providers/outscale/outscale/latest/docs/resources/volume_link) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable_keypair"></a> [enable\_keypair](#input\_enable\_keypair) | Enable creation of an SSH keypair | `bool` | `false` | no |
| <a name="input_enable_security_groups"></a> [enable\_security\_groups](#input\_enable\_security\_groups) | Enable creation of security groups defined in the security\_groups variable | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Deployment environment (dev, staging, or prod) | `string` | n/a | yes |
| <a name="input_keypair_name"></a> [keypair\_name](#input\_keypair\_name) | Name for the SSH keypair (required when enable\_keypair is true) | `string` | `null` | no |
| <a name="input_keypair_public_key"></a> [keypair\_public\_key](#input\_keypair\_public\_key) | Public key material for the SSH keypair. Provide via environment variable or tfvars, never hardcode | `string` | `null` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name used for resource naming and tagging. Must be lowercase alphanumeric with hyphens only | `string` | n/a | yes |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | Map of security groups to create when enable\_security\_groups is true. Keys are referenced by security\_group\_keys in VM definitions | <pre>map(object({<br/>    description = string<br/>    net_id      = string<br/>    inbound_rules = optional(list(object({<br/>      from_port_range                   = number<br/>      to_port_range                     = number<br/>      ip_protocol                       = string<br/>      ip_range                          = optional(string)<br/>      security_group_account_id_to_link = optional(string)<br/>      security_group_name_to_link       = optional(string)<br/>    })), [])<br/>    outbound_rules = optional(list(object({<br/>      from_port_range                   = number<br/>      to_port_range                     = number<br/>      ip_protocol                       = string<br/>      ip_range                          = optional(string)<br/>      security_group_account_id_to_link = optional(string)<br/>      security_group_name_to_link       = optional(string)<br/>    })), [])<br/>    tags = optional(map(string), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_vms"></a> [vms](#input\_vms) | Map of VM role definitions. Each key is a role name (e.g., 'frontend', 'backend') with its configuration including count, image, type, networking, and optional volumes | <pre>map(object({<br/>    count                    = number<br/>    image_id                 = string<br/>    vm_type                  = string<br/>    subnet_id                = string<br/>    keypair_name             = optional(string)<br/>    security_group_ids       = optional(list(string), [])<br/>    security_group_keys      = optional(list(string), [])<br/>    placement_subregion_name = optional(string)<br/>    enable_public_ip         = optional(bool, false)<br/>    deletion_protection      = optional(bool, false)<br/>    user_data                = optional(string)<br/>    block_device_mappings = optional(list(object({<br/>      device_name = string<br/>      bsu = object({<br/>        volume_size           = number<br/>        volume_type           = optional(string, "gp2")<br/>        iops                  = optional(number)<br/>        snapshot_id           = optional(string)<br/>        delete_on_vm_deletion = optional(bool, true)<br/>      })<br/>    })), [])<br/>    volumes = optional(map(object({<br/>      size           = number<br/>      type           = optional(string, "gp2")<br/>      iops           = optional(number)<br/>      snapshot_id    = optional(string)<br/>      device_name    = string<br/>      subregion_name = optional(string)<br/>      tags           = optional(map(string), {})<br/>    })), {})<br/>    tags = optional(map(string), {})<br/>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_keypair_fingerprint"></a> [keypair\_fingerprint](#output\_keypair\_fingerprint) | Fingerprint of the created keypair (null if keypair creation is disabled) |
| <a name="output_keypair_id"></a> [keypair\_id](#output\_keypair\_id) | ID of the created keypair (null if keypair creation is disabled) |
| <a name="output_keypair_name"></a> [keypair\_name](#output\_keypair\_name) | Name of the created keypair (null if keypair creation is disabled) |
| <a name="output_public_ip_ids"></a> [public\_ip\_ids](#output\_public\_ip\_ids) | Map of public IP allocation IDs keyed by VM key |
| <a name="output_public_ips"></a> [public\_ips](#output\_public\_ips) | Map of public IP addresses keyed by VM key |
| <a name="output_security_group_ids"></a> [security\_group\_ids](#output\_security\_group\_ids) | Map of security group IDs keyed by security group name |
| <a name="output_vm_details"></a> [vm\_details](#output\_vm\_details) | Map of VM details including ID, private IP, public IP, state, and type |
| <a name="output_vm_ids"></a> [vm\_ids](#output\_vm\_ids) | Map of VM IDs keyed by flattened VM key (role-index) |
| <a name="output_vm_private_ips"></a> [vm\_private\_ips](#output\_vm\_private\_ips) | Map of VM private IPs keyed by flattened VM key |
| <a name="output_vm_public_ips"></a> [vm\_public\_ips](#output\_vm\_public\_ips) | Map of VM public IPs keyed by flattened VM key (empty string if no public IP) |
| <a name="output_volume_ids"></a> [volume\_ids](#output\_volume\_ids) | Map of volume IDs keyed by compound key (vm\_key:vol\_key) |
| <a name="output_volume_link_states"></a> [volume\_link\_states](#output\_volume\_link\_states) | Map of volume link states keyed by compound key (vm\_key:vol\_key) |
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
