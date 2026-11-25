## ADDED Requirements

### Requirement: Source/destination check
A role SHALL accept the optional field `is_source_dest_checked` (bool, default `null`). A set value SHALL be planned on the role's VMs; a `null` value SHALL be omitted so the API default applies and the plan shows no change compared with the previous release.

#### Scenario: Source/destination check disabled
- **WHEN** a role sets `is_source_dest_checked = false`
- **THEN** its VMs are planned with `is_source_dest_checked = false`

#### Scenario: Omitted
- **WHEN** a role omits `is_source_dest_checked`
- **THEN** its VMs are planned as before, with the API default and an empty second plan
