## MODIFIED Requirements

### Requirement: Security group attachment
A VM SHALL be attached to the security groups listed in its role's `security_group_ids` followed by the groups created by the module whose keys are listed in `security_group_keys`. Every entry of `security_group_keys` SHALL be a key of `security_groups` with `enable_security_groups` true; otherwise the plan fails with a message naming the role.

#### Scenario: Created group by key
- **WHEN** `enable_security_groups = true`, `security_groups` has the key `web` and a role sets `security_group_keys = ["web"]`
- **THEN** the role's VMs are attached to the security group created for `web`

#### Scenario: Existing group by id
- **WHEN** a role sets `security_group_ids = ["sg-12345678"]`
- **THEN** its VMs are attached to `sg-12345678`

#### Scenario: Unknown security group key
- **WHEN** `enable_security_groups = true` and a role sets `security_group_keys = ["missing"]` that is not a key of `security_groups`
- **THEN** the plan fails with "security_group_keys of role web references a key that is not in security_groups, or enable_security_groups is false."

#### Scenario: Security groups disabled
- **WHEN** `enable_security_groups = false` and a role sets `security_group_keys = ["web"]`
- **THEN** the plan fails with the same message
