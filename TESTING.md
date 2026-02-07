# Testing

## Test Framework

This module uses Terraform's native test framework (`.tftest.hcl` files) for validation.

## Running Tests

```bash
# Initialize the module
terraform init

# Run all tests (plan-mode, no real resources created)
terraform test

# Run with verbose output
terraform test -verbose
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

## CI Integration

Tests run automatically in the GitLab CI pipeline:

- **validate:opentofu** — `tofu init`, `tofu validate`, `tofu fmt -check`
- **validate:tflint** — linter with all rules enabled
- **pre-commit** — runs all pre-commit hooks including terraform fmt and docs

## Examples as Validation

Both examples are validated in CI:

```bash
cd examples/basic && terraform init && terraform validate
cd examples/complete && terraform init && terraform validate
```
