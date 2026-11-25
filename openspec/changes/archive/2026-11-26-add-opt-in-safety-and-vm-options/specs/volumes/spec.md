## ADDED Requirements

### Requirement: Snapshot on volume termination
Each entry of a role's `volumes` SHALL accept the optional field `termination_snapshot_name` (string, default `null`). When set, the volume SHALL be planned with that value so that a snapshot with that name is taken when the volume is destroyed. When `null`, the argument SHALL be omitted and no snapshot is requested.

#### Scenario: Snapshot name set
- **WHEN** volume `data` sets `termination_snapshot_name = "backend-data-final"`
- **THEN** every volume created from that entry is planned with `termination_snapshot_name = "backend-data-final"`

#### Scenario: Omitted
- **WHEN** a volume omits `termination_snapshot_name`
- **THEN** the volume is planned without a termination snapshot and the plan shows no change compared with the previous release
