# Standards Applied

This module follows all 13 standards from `agent-os/standards/`:

## Repository Structure (`repo-structure.md`)
- Pre-commit hooks: v6.0.0 general + v1.103.0 terraform
- Mise tool versions: opentofu 1.11, tflint 0.56.0, etc.
- TFLint with all 10 rules enabled
- EditorConfig: 2-space indent for .tf/.hcl, LF endings
- Git-cliff changelog generator
- GitLab CI pipeline (validate + release stages)
- Apache 2.0 license, Copyright 2026 LEMINNOV

## Global Standards
- **Code Style**: terraform fmt, 2-space indent, for_each over count, block ordering
- **Documentation**: README with badges/features/usage, terraform-docs markers, CHANGELOG
- **Security**: sensitive vars marked, no secrets in code, SG deny-all default
- **Versioning**: semver, v0.1.0 initial, git tags

## Terraform Standards
- **Module Structure**: main.tf, variables.tf, outputs.tf, versions.tf, locals.tf + split files
- **Naming**: snake_case, `this` for single resources, common_tags pattern
- **Outputs**: IDs and connection info, grouped by resource, descriptions required
- **Providers**: outscale/outscale ~> 1.0, no provider config in module
- **State**: no backend in module, remote state for root modules only
- **Tech Stack**: OpenTofu compatible, native test framework
- **Variables**: description + type required, validation blocks, ordered required-first

## Testing Standards
- **Terraform Tests**: .tftest.hcl in tests/, plan-mode tests, examples as tests
