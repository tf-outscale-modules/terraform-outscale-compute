## ADDED Requirements

### Requirement: Optional keypair
The module SHALL create one SSH keypair only when `enable_keypair` is true (default `false`). Its name SHALL be `keypair_name` when set, otherwise `<project_name>-<environment>-keypair`, and it SHALL carry the common tags.

#### Scenario: Disabled by default
- **WHEN** `enable_keypair` is not set
- **THEN** the plan contains no keypair and `keypair_id`, `keypair_name` and `keypair_fingerprint` are `null`

#### Scenario: Default name
- **WHEN** `enable_keypair = true`, `keypair_public_key` is set, `keypair_name` is not set, `project_name = "myproject"` and `environment = "dev"`
- **THEN** the keypair is named `myproject-dev-keypair`

#### Scenario: Explicit name
- **WHEN** `enable_keypair = true` and `keypair_name = "ops-key"`
- **THEN** the keypair is named `ops-key`

### Requirement: Sensitive public key
`keypair_public_key` SHALL be a sensitive string with default `null`. The module SHALL refuse to create the keypair without it.

#### Scenario: Missing public key
- **WHEN** `enable_keypair = true` and `keypair_public_key` is not set
- **THEN** the plan fails with "keypair_public_key is required when enable_keypair is true."

#### Scenario: Public key in plan output
- **WHEN** `keypair_public_key` is set
- **THEN** its value is redacted in plan output

### Requirement: Keypair is independent of VM keypairs
The keypair created by the module SHALL NOT be attached automatically to VMs; a VM uses a keypair only through the `keypair_name` of its role.

#### Scenario: Keypair created, role without keypair_name
- **WHEN** `enable_keypair = true` and a role omits `keypair_name`
- **THEN** the role's VMs are planned without a keypair name
