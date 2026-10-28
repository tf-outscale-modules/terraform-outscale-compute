# module-contract Specification

## Purpose
Cross-cutting contract of the module: supported tooling and provider, required inputs and validations, common tags and outputs.

## Requirements

### Requirement: Supported tooling and provider
The module SHALL declare `required_version = ">= 1.5"` and SHALL pin `outscale/outscale` with `~> 1.8` in `versions.tf`. It SHALL work on OpenTofu and Terraform.

#### Scenario: Provider resolution
- **WHEN** the module is initialised
- **THEN** the outscale provider resolves to a 1.x release at or above 1.8

#### Scenario: Version below the floor
- **WHEN** the module is initialised with OpenTofu or Terraform 1.4
- **THEN** initialisation fails on the `required_version` constraint

### Requirement: No provider or backend configuration
The module SHALL NOT contain `provider {}` or `backend {}` blocks; the caller configures the Outscale provider (credentials, region) and the state backend.

#### Scenario: Provider block inside the module
- **WHEN** a change adds a `provider "outscale" {}` or `backend` block to a module file
- **THEN** it is moved to the caller or to the example's own configuration, and the module only declares `required_providers`

### Requirement: Required inputs
The module SHALL require `project_name`, `environment` and `vms`; every other input SHALL be optional with a default. `project_name` and `environment` are strings, `vms` is a map of role objects.

#### Scenario: Minimal call
- **WHEN** the module is called with `project_name`, `environment` and one role in `vms`
- **THEN** the plan contains the VMs of that role and no security group, keypair, volume, public IP or flexible GPU

#### Scenario: Missing required input
- **WHEN** the module is called without `project_name`, `environment` or `vms`
- **THEN** the plan fails because the input is required

### Requirement: Project name validation
`project_name` SHALL start with a lowercase letter, contain only lowercase letters, digits and hyphens, and be 1 to 63 characters long.

#### Scenario: Valid project name
- **WHEN** `project_name = "myproject"`
- **THEN** the plan succeeds

#### Scenario: Rejected project name
- **WHEN** `project_name = "Invalid_Name!"`
- **THEN** the plan fails with "Project name must start with a letter, contain only lowercase letters, digits, and hyphens, and be 1-63 characters."

#### Scenario: Project name starting with a digit
- **WHEN** `project_name = "1project"`
- **THEN** the plan fails with the same project name error

#### Scenario: Project name too long
- **WHEN** `project_name` is 64 characters long
- **THEN** the plan fails with the same project name error

### Requirement: Environment validation
`environment` SHALL be one of `dev`, `staging` or `prod`.

#### Scenario: Rejected environment
- **WHEN** `environment = "production"`
- **THEN** the plan fails with "Environment must be dev, staging, or prod."

### Requirement: Common tags
Every resource that supports tags, except flexible GPUs, SHALL carry the tags `Project` (the `project_name`), `Environment` (the `environment`) and `ManagedBy = "terraform"`, merged with the `tags` input (default `{}`). A key of `tags` that equals one of these three keys SHALL override it.

#### Scenario: Default tags
- **WHEN** the module is called with `project_name = "myproject"`, `environment = "dev"` and no `tags`
- **THEN** every tagged resource carries `Project = "myproject"`, `Environment = "dev"` and `ManagedBy = "terraform"`

#### Scenario: Additional tags
- **WHEN** `tags = { Team = "platform" }`
- **THEN** every tagged resource carries `Team = "platform"` in addition to the three default tags

#### Scenario: Override of a default tag
- **WHEN** `tags = { ManagedBy = "ci" }`
- **THEN** every tagged resource carries `ManagedBy = "ci"`

### Requirement: VM outputs
The module SHALL expose the maps `vm_ids`, `vm_private_ips`, `vm_public_ips` and `vm_details` keyed by VM key `<role>-<index>`; `vm_details` holds `vm_id`, `private_ip`, `public_ip`, `state` and `vm_type`. `public_ip_ids` and `public_ips` SHALL be keyed by VM key and hold only the public IPs allocated by the module.

#### Scenario: Minimal call outputs
- **WHEN** the module is called with one role of count 2 named `web` and nothing optional
- **THEN** `vm_ids` has the keys `web-0` and `web-1`, `public_ips` is empty and the three keypair outputs are `null`

### Requirement: Feature outputs
The module SHALL expose `security_group_ids` keyed by the key of `security_groups`, `volume_ids` and `volume_link_states` keyed by `<vm_key>:<volume_key>`, and `flexible_gpu_ids` and `flexible_gpu_details` keyed by `<gpu_key>:<vm_key>`. Each map SHALL be empty when its resource is not created.

#### Scenario: Feature outputs when features are off
- **WHEN** `enable_security_groups` and `enable_flexible_gpus` are false and no role declares volumes
- **THEN** `security_group_ids`, `volume_ids`, `volume_link_states`, `flexible_gpu_ids` and `flexible_gpu_details` are empty maps

### Requirement: Keypair outputs
The module SHALL expose `keypair_id`, `keypair_name` and `keypair_fingerprint`, each `null` when `enable_keypair` is false. `keypair_fingerprint` SHALL be sensitive and no other output SHALL be sensitive.

#### Scenario: Keypair fingerprint hidden
- **WHEN** `enable_keypair = true` and the outputs are shown
- **THEN** `keypair_fingerprint` is displayed as sensitive
