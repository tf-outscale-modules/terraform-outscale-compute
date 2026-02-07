# Outscale Compute Terraform Module — Implementation Plan

## Context

This is a new Terraform module for provisioning Outscale cloud VMs. The module's core feature is a **role-based VM map** where users define roles (e.g., `frontend`, `backend`) with counts, and the module flattens them into individual VM instances using `for_each` for stable resource addresses.

**External references** (for examples/tests only, not module dependencies):
- Networking: `https://github.com/tf-outscale-modules/terraform-outscale-networking`
- Storage: `https://github.com/tf-outscale-modules/terraform-outscale-storage`

## Key Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| VM flattening | `merge([for role, cfg in var.vms : { for i in range(cfg.count) : "${role}-${i}" => ... }]...)` | Stable keys; removing a VM doesn't shift others |
| Security groups | External `security_group_ids` + internal `security_group_keys` referencing `security_groups` map | Avoids circular references |
| Volumes | Nested `volumes` map per VM role, flattened to `"{vm_key}:{vol_key}"` | Volumes coupled to VMs; subregion auto-derived |
| Public IPs | Per-role `enable_public_ip` boolean | Simple; all VMs in a role get same treatment |
| Naming | `{project_name}-{environment}-{role}-{index}` | Consistent, unique, descriptive |
| Tags | `common_tags` + `{ Name, Role }` + role-specific `tags` | Matches networking/storage module patterns |
| Keypair | `count = var.enable_keypair ? 1 : 0` | Single resource, simple toggle |

## Tasks

1. Save spec documentation
2. Repository scaffolding (pre-commit, mise, tflint, editorconfig, cliff, gitignore, license, CI)
3. Module core — `versions.tf`
4. Module core — `variables.tf`
5. Module core — `locals.tf`
6. Module resources — `main.tf`, `security_groups.tf`, `volumes.tf`, `public_ips.tf`, `keypair.tf`
7. Module outputs — `outputs.tf`
8. Examples — `basic/` and `complete/`
9. Tests — `tests/main.tftest.hcl`
10. Documentation — `README.md`, `SECURITY.md`, `TESTING.md`, `CHANGELOG.md`

## Critical Files

| File | Why Critical |
|------|-------------|
| `locals.tf` | VM map flattening is the core pattern |
| `variables.tf` | Defines the entire input interface |
| `main.tf` | VM resource with for_each, dynamic blocks, SG key resolution |
| `examples/complete/main.tf` | Validates the full interface works end-to-end |
