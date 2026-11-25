# Changelog

All notable changes to this project will be documented in this file.

## [1.3.0] - 2026-11-25
- Add opt-in security group egress removal, volume termination snapshot and VM source/destination check options

Three optional attributes, all null by default and omitted when unset, so
existing deployments see no diff: remove_default_outbound_rule on security
groups, termination_snapshot_name on volumes and is_source_dest_checked on
VM roles. The complete example shows the secure settings and SECURITY.md
now states that Outscale adds an allow-all outbound rule to new groups.
Verified live on provider 1.9.0 with empty second plans.

Switching remove_default_outbound_rule on for an existing group forces its
replacement, which fails while the group is the only one of a VM: set it
when the group is created. No other upgrade action.
- Fix security group key, volume subregion and docs gaps

A precondition gives a readable error for an unknown
security_group_keys entry or disabled security groups. A volume with no
subregion follows its VM. The dead flexible GPU tags local is removed
(flexible GPUs have no tags), and the security_group_ids description
and README known limitations are corrected. No upgrade action.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
- Move from Agent OS to OpenSpec and publish the baseline specs

Planning moves from Agent OS to OpenSpec: agent-os/ is removed and the
engineering standards now come from the quality, repository and terraform
OpenSpec stores. openspec/config.yaml follows the terraform-module profile
(stores pinned at quality v1.2.6, repository v4.1.0, terraform v1.2.6) and
AGENTS.md, imported by CLAUDE.md, routes to them. openspec/specs/ holds the
baseline specification of the module as released, produced by the archived
adopt-openspec change. The openspec-* skills are installed for Claude Code
and OpenCode, openspec 1.14.3 and node are pinned in mise.toml with the
spec-validate and spec-setup tasks, and the validate:specs CI job runs
openspec validate --all --strict.

CI: mise 2026.10.17 resolves tools through mise-versions.jdx.dev instead of
the rate-limited api.github.com, and the pre-commit caches are keyed on the
toolchain files instead of the branch, so a toolchain change starts a fresh
cache. The module contract is unchanged.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
- feat: add VM vTPM, boot mode, secure boot and shutdown behavior

- vms: add tpm_enabled, boot_mode, secure_boot_action and
  shutdown_behavior_configuration.
- Tag the keypair with the common tags (keypair tags since provider 1.1).
- Create each flexible GPU in its VM subregion: since 1.8 the provider
  picks the first subregion offering the model when none is set.
- Bump the outscale provider constraint to ~> 1.8 (module and examples).

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
- Ensures `mise.toml` ends with a newline

Fixes a minor formatting issue in the `mise.toml` file by
ensuring it ends with a newline character. This avoids
potential issues with some text editors or tools that
expect this convention.
- Adds tofu apply/destroy tasks

Adds `tofu-apply` and `tofu-destroy` tasks to the mise.toml configuration.

These tasks simplify the deployment and destruction of infrastructure
using tofu (Terraform OpenFormat Utility) with a pre-defined SSH public key.
- Refactors example to support LLM instance

Updates the complete example to include an LLM instance.

Renames "backend" to "llm" in module configurations for clarity and consistency.
Modifies security group and instance settings to accommodate the LLM role.
Updates project name to "outscale-compute".
- Generates SSH key for example and updates ignore file.

Adds a task to generate an SSH key for the complete example.
Updates the .gitignore file to exclude the generated key and its public counterpart, preventing them from being committed to the repository.
## [1.0.0] - 2026-02-07
- Updates outscale provider version

Updates the outscale provider version in the README to reflect a more general version constraint. This allows for greater flexibility in version selection.
- Adds flexible GPU support and updates docs

Adds support for flexible GPUs to the module, allowing users to define and create flexible GPUs as part of their infrastructure.

Updates the README to document the new flexible GPU functionality, including inputs, outputs, and resource types.

Removes example key files.
- Adds experimental OpenSpec workflow skills

Introduces a suite of experimental skills for managing OpenSpec workflows, including:

- Change application and archiving.
- Bulk archiving of changes.
- Change continuation and exploration.
- Fast-forward change creation.
- Delta spec syncing.
- Implementation verification.
- Guided onboarding.

These skills streamline the OpenSpec process, from initial exploration to final archiving, and include corresponding prompts and skill definitions for use within a larger agentic system.
- Reduces VM counts in example

Reduces the number of frontend and backend VMs in the complete example to better reflect a minimal deployment.
This change helps to reduce resource consumption when deploying the example.
- Adds example validation tasks

Adds tasks to validate the Terraform examples.

This includes tasks to initialize and validate all examples,
as well as a task to validate the complete example with the example SSH key.
- Adds flexible GPU support

Implements the ability to allocate and attach Outscale flexible GPUs to VMs based on their role.

This feature allows users to define GPU requirements per VM role, enabling automatic allocation and attachment of fGPUs. It introduces `enable_flexible_gpus` and `flexible_gpus` variables to control and configure GPU allocation.
The module also outputs the created `flexible_gpu_ids` and `flexible_gpu_details`.

Updates the networking module configuration to use ip_range instead of net_cidr_block and cidr_block.
Also adds enable_internet_service and tags to the networking module.
- Enhances module with validations and documentation

Improves the module by adding input validations for project name, environment, and VM count to ensure proper configuration.

Includes comprehensive documentation generated by terraform-docs, detailing requirements, providers, resources, inputs, and outputs.

Updates security guidelines and testing documentation to reflect changes and best practices.
- Consolidates Terraform resource definitions

Moves all resource definitions into a single main.tf file.

This change streamlines the module structure and improves
readability by centralizing the resource configurations.
Previously, resources were spread across multiple files,
making it harder to understand the overall infrastructure setup.
- Adds Outscale compute module with role-based VMs

Introduces a Terraform module for provisioning Outscale cloud virtual machines.

The module offers role-based VM provisioning, security groups, volume management, public IP allocation, and SSH keypair creation. It uses a flattening technique to create a stable and predictable infrastructure.

This commit also includes comprehensive documentation, examples, and automated tests.
- Initial commit

