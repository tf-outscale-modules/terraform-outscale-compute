## ADDED Requirements

### Requirement: Optional removal of the default outbound rule
Each entry of `security_groups` SHALL accept the optional field `remove_default_outbound_rule` (bool, default `null`). When it is `true`, the group SHALL be created without the allow-all outbound rule Outscale adds to new groups, so that only the group's own `outbound_rules` apply. When it is `null` or `false`, the group SHALL keep the default rule, exactly as before this field existed.

#### Scenario: Default rule removed
- **WHEN** group `web` sets `remove_default_outbound_rule = true`
- **THEN** the plan contains the group with `remove_default_outbound_rule = true`

#### Scenario: Omitted keeps current behaviour
- **WHEN** a group omits `remove_default_outbound_rule`
- **THEN** the plan shows no change compared with the previous release and no outbound rule is added or removed

#### Scenario: Restrictive egress
- **WHEN** group `web` sets `remove_default_outbound_rule = true` and declares one outbound rule on port 443/tcp
- **THEN** the plan contains the group and the single rule `web:outbound:0`

#### Scenario: Group without any outbound rule
- **WHEN** group `web` sets `remove_default_outbound_rule = true` and declares no `outbound_rules`
- **THEN** the plan succeeds and the VMs attached to the group have no outbound access
