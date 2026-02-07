# Changelog

All notable changes to this project will be documented in this file.

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
