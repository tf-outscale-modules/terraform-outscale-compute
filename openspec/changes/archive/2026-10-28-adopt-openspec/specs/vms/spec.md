## ADDED Requirements

### Requirement: Role map flattening
The module SHALL create `count` VMs for every role of `vms`, each addressed as `outscale_vm.this["<role>-<index>"]` with index from 0, using the role's `image_id`, `vm_type` and `subnet_id`.

#### Scenario: Single VM
- **WHEN** `vms = { web = { count = 1, image_id = "ami-12345678", vm_type = "tinav5.c1r1p1", subnet_id = "subnet-12345678" } }`
- **THEN** the plan contains exactly one VM, `web-0`, with that image and type

#### Scenario: Several roles
- **WHEN** `vms` declares `frontend` with count 3 and `backend` with count 2
- **THEN** the plan contains five VMs: `frontend-0` to `frontend-2` and `backend-0` and `backend-1`

### Requirement: VM count validation
Every role of `vms` SHALL have `count` greater than or equal to 1.

#### Scenario: Rejected count
- **WHEN** a role is declared with `count = 0`
- **THEN** the plan fails with "VM count must be at least 1 for each role."

### Requirement: Naming and VM tags
The name of the VM at index `i` of role `r` SHALL be `<project_name>-<environment>-<r>-<i>` and SHALL be set as its `Name` tag. Each VM SHALL also carry the tag `Role = <r>`, the common tags and the tags of the role. On a conflicting key the role's `tags` win over `Role` and `Name`, which win over the common tags.

#### Scenario: Naming pattern
- **WHEN** `project_name = "myproject"`, `environment = "prod"` and role `web` has count 2
- **THEN** the VMs are tagged `Name = "myproject-prod-web-0"` and `Name = "myproject-prod-web-1"`, both with `Role = "web"`

#### Scenario: Role tags
- **WHEN** a role declares `tags = { Tier = "front" }`
- **THEN** its VMs carry `Tier = "front"` besides the common tags, `Name` and `Role`

### Requirement: VM definition fields and defaults
A role SHALL accept the optional fields `keypair_name`, `placement_subregion_name`, `user_data`, `tpm_enabled`, `boot_mode`, `secure_boot_action`, `shutdown_behavior_configuration`, `block_device_mappings` and `tags`, left unset when omitted, plus `security_group_ids` and `security_group_keys` (default `[]`), `enable_public_ip` and `deletion_protection` (default `false`).

#### Scenario: Deletion protection passed through
- **WHEN** a role sets `deletion_protection = true`
- **THEN** its VMs are planned with deletion protection enabled

#### Scenario: Boot options
- **WHEN** a role sets `tpm_enabled = true`, `boot_mode = "uefi"` and `secure_boot_action = "enable"`
- **THEN** its VMs are planned with those three arguments

#### Scenario: Shutdown behaviour
- **WHEN** a role sets `shutdown_behavior_configuration = { guest_action = "stop", host_action = "restart" }`
- **THEN** its VMs carry one `shutdown_behavior_configuration` block with those actions

#### Scenario: No shutdown behaviour
- **WHEN** a role omits `shutdown_behavior_configuration`
- **THEN** its VMs carry no `shutdown_behavior_configuration` block

### Requirement: Block device mappings
Each entry of `block_device_mappings` SHALL produce one `block_device_mappings` block with its `device_name` and a `bsu` block built from `volume_size`, `volume_type` (default `gp2`), `iops`, `snapshot_id` and `delete_on_vm_deletion` (default `true`).

#### Scenario: Root volume sizing
- **WHEN** a role declares one mapping with `device_name = "/dev/sda1"` and `bsu = { volume_size = 50 }`
- **THEN** its VMs carry one block device mapping of 50 GiB with type `gp2` and deletion with the VM

### Requirement: Security group attachment
A VM SHALL be attached to the security groups listed in its role's `security_group_ids` followed by the groups created by the module whose keys are listed in `security_group_keys`.

#### Scenario: Created group by key
- **WHEN** `enable_security_groups = true`, `security_groups` has the key `web` and a role sets `security_group_keys = ["web"]`
- **THEN** the role's VMs are attached to the security group created for `web`

#### Scenario: Existing group by id
- **WHEN** a role sets `security_group_ids = ["sg-12345678"]`
- **THEN** its VMs are attached to `sg-12345678`

### Requirement: Public IPs per role
The module SHALL allocate one public IP and link it to the VM for every VM whose role sets `enable_public_ip = true`, addressed by the VM key, and SHALL NOT allocate any for the other VMs. Each public IP SHALL carry the common tags and `Name = "<vm name>-pip"`.

#### Scenario: Mixed roles
- **WHEN** role `public` (count 2) sets `enable_public_ip = true` and role `private` (count 1) leaves the default
- **THEN** the plan contains two public IPs and two links, for `public-0` and `public-1`, and none for `private-0`

#### Scenario: Public IP outputs
- **WHEN** a VM has a public IP
- **THEN** `public_ip_ids` and `public_ips` have an entry for its VM key
