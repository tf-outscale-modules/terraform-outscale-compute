# volumes Specification

## Purpose
Additional volumes created and linked per VM instance: sizing, subregion, tags and outputs.

## Requirements

### Requirement: Volumes per VM instance
For every VM of a role and every entry of the role's `volumes` map (default `{}`), the module SHALL create one volume addressed `<vm_key>:<volume_key>` with the entry's `size`, `type` (default `gp2`), `iops` and `snapshot_id`, and one volume link to that VM at the entry's `device_name`.

#### Scenario: Two volumes on two VMs
- **WHEN** role `backend` has count 2 and declares the volumes `data` and `logs`
- **THEN** the plan contains four volumes and four links, among them `backend-0:data` and `backend-1:logs`

#### Scenario: No volumes
- **WHEN** a role omits `volumes`
- **THEN** no volume or link is planned for it

### Requirement: Volume subregion
A volume SHALL be created in its own `subregion_name` when set, otherwise in the subregion of its VM: the `placement_subregion_name` of its role when set, else the subregion the VM was placed in.

#### Scenario: Subregion from the VM
- **WHEN** the role sets `placement_subregion_name = "eu-west-2a"` and the volume sets no `subregion_name`
- **THEN** the volume is planned in `eu-west-2a`

#### Scenario: Explicit subregion
- **WHEN** the volume sets `subregion_name = "eu-west-2b"`
- **THEN** the volume is planned in `eu-west-2b`

#### Scenario: No subregion anywhere
- **WHEN** neither the volume nor its role sets a subregion
- **THEN** the plan succeeds and the volume takes the subregion of its VM once the VM exists

### Requirement: Volume tags
A volume SHALL carry the common tags, `Name = "<vm name>-<volume_key>"`, `Role = <role>` and the entry's `tags`, the entry's tags winning on a conflicting key.

#### Scenario: Volume name
- **WHEN** `project_name = "myproject"`, `environment = "dev"`, and role `backend` declares volume `data`
- **THEN** the volume of `backend-0` is tagged `Name = "myproject-dev-backend-0-data"` and `Role = "backend"`

### Requirement: Volume outputs
`volume_ids` SHALL map each volume key to its id and `volume_link_states` SHALL map each volume key to the state of its link.

#### Scenario: Output keys
- **WHEN** a role of count 1 named `db` declares volume `data`
- **THEN** `volume_ids` and `volume_link_states` have the key `db-0:data`
