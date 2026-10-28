## MODIFIED Requirements

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
