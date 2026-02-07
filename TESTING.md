# Testing

## Test Framework

This module uses Terraform's native test framework (`.tftest.hcl` files) for validation.

## Running Tests

```bash
# Initialize the module
tofu init

# Run all tests (plan-mode, no real resources created)
tofu test

# Run with verbose output
tofu test -verbose
```

## What's Tested

| Test | Description |
|------|-------------|
| `single_vm` | Single VM creation with minimal config |
| `multi_role_vms` | Multi-role VM counts (3 frontend + 2 backend = 5 total) |
| `public_ip_creation` | Public IP allocation only for roles with `enable_public_ip = true` |
| `security_groups_disabled` | No SGs created when `enable_security_groups = false` |
| `security_groups_enabled` | SG and rules created when enabled |
| `volume_creation` | Volume creation and linking per VM (2 VMs x 2 volumes = 4) |
| `naming_convention` | Names follow `{project}-{env}-{role}-{index}` pattern |
| `keypair_disabled` | No keypair when `enable_keypair = false` |
| `keypair_enabled` | Keypair created with correct name when enabled |
| `invalid_environment` | Rejects invalid environment values |
| `invalid_project_name` | Rejects project names with invalid characters |
| `invalid_vm_count` | Rejects VM count of 0 |
| `tags_propagation` | Verifies common, custom, and role tags are all merged |
| `block_device_mappings` | Exercises block device mapping configuration |
| `deletion_protection` | Verifies deletion protection flag is passed through |

## CI Integration

Tests run automatically in the GitLab CI pipeline:

- **validate:opentofu** — `tofu init`, `tofu validate`, `tofu fmt -check`
- **validate:tflint** — linter with all rules enabled
- **pre-commit** — runs all pre-commit hooks including terraform fmt and docs

## Examples as Validation

Both examples are validated in CI:

```bash
cd examples/basic && tofu init && tofu validate
cd examples/complete && tofu init && tofu validate
```
