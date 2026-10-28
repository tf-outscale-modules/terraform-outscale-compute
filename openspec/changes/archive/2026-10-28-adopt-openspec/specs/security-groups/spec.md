## ADDED Requirements

### Requirement: Optional security groups
The module SHALL create one security group for every entry of `security_groups` (default `{}`) only when `enable_security_groups` is true (default `false`), and none otherwise. Each group SHALL have the entry's `description` and `net_id`, the name `<project_name>-<environment>-<key>`, and the tags common tags, `Name` equal to that name, and the entry's `tags`.

#### Scenario: Disabled by default
- **WHEN** `security_groups` is declared and `enable_security_groups` is not set
- **THEN** the plan contains no security group and no rule, and `security_group_ids` is empty

#### Scenario: Enabled
- **WHEN** `enable_security_groups = true` and `security_groups` has the key `web` with `project_name = "myproject"` and `environment = "dev"`
- **THEN** the plan contains a security group named `myproject-dev-web` in the given `net_id`

### Requirement: Inbound and outbound rules
Each security group SHALL get one rule resource per element of its `inbound_rules` (flow `Inbound`) and `outbound_rules` (flow `Outbound`), both defaulting to `[]`, addressed `<key>:inbound:<index>` and `<key>:outbound:<index>`. A rule SHALL use `from_port_range`, `to_port_range`, `ip_protocol` and the optional `ip_range`, `security_group_account_id_to_link` and `security_group_name_to_link`. A group without rules SHALL be created without any rule.

#### Scenario: One inbound and one outbound rule
- **WHEN** group `web` declares an inbound rule on port 443/tcp from `0.0.0.0/0` and an outbound rule with protocol `-1`
- **THEN** the plan contains the rules `web:inbound:0` and `web:outbound:0` with the flows `Inbound` and `Outbound`

#### Scenario: Group without rules
- **WHEN** a group declares neither `inbound_rules` nor `outbound_rules`
- **THEN** the plan contains the group and no rule for it

### Requirement: Security group output
`security_group_ids` SHALL map each key of `security_groups` to the id of its created group.

#### Scenario: Output keys
- **WHEN** `enable_security_groups = true` and `security_groups` has the keys `web` and `db`
- **THEN** `security_group_ids` has the keys `web` and `db`
