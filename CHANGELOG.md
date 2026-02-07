# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added

- Flexible GPU support: allocate and attach Outscale fGPUs to VMs by role
- `enable_flexible_gpus` and `flexible_gpus` variables
- `flexible_gpu_ids` and `flexible_gpu_details` outputs
- Flexible GPU tests (disabled, enabled, multi-model, validation)

## [0.1.0] - 2026-02-07

- Initial release
- Role-based VM provisioning with `for_each` flattening
- Optional security group creation with inbound/outbound rules
- Volume creation and attachment per VM role
- Public IP allocation and association per role
- Optional SSH keypair creation
- Consistent naming pattern: `{project}-{environment}-{role}-{index}`
- Common tags with merge support
- Basic and complete examples
- Plan-mode test suite
- GitLab CI pipeline with validation, linting, and release automation
