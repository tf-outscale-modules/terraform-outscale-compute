# flexible-gpus Specification

## Purpose
Optional flexible GPUs allocated and linked per VM of a role, with role validation and outputs.

## Requirements

### Requirement: Optional flexible GPUs
The module SHALL create flexible GPUs from `flexible_gpus` (default `{}`) only when `enable_flexible_gpus` is true (default `false`), and none otherwise.

#### Scenario: Disabled by default
- **WHEN** `flexible_gpus` is declared and `enable_flexible_gpus` is not set
- **THEN** the plan contains no flexible GPU and no link, and `flexible_gpu_ids` is empty

### Requirement: One GPU per VM of the role
For every entry of `flexible_gpus` the module SHALL create one flexible GPU for each VM of the role named by `vm_role`, addressed `<gpu_key>:<vm_key>`, with the entry's `model_name`, `generation` (unset when omitted) and `delete_on_vm_deletion` (default `true`), in the subregion of that VM's `placement_subregion_name`.

#### Scenario: GPU on every VM of a role
- **WHEN** `enable_flexible_gpus = true`, role `backend` has count 2 and `flexible_gpus = { compute = { model_name = "nvidia-p100", vm_role = "backend" } }`
- **THEN** the plan contains the flexible GPUs `compute:backend-0` and `compute:backend-1` and none for other roles

#### Scenario: Several models on one role
- **WHEN** two entries target the same role with different models
- **THEN** each VM of the role receives one GPU per entry

### Requirement: GPU links
The module SHALL create one flexible GPU link per VM that receives at least one GPU, attaching all GPUs of that VM in a single link addressed by the VM key.

#### Scenario: One link for two GPUs
- **WHEN** two entries target role `backend` of count 1
- **THEN** the plan contains one link for `backend-0` listing both GPUs

### Requirement: GPU role validation
Every `vm_role` of `flexible_gpus` SHALL be a key of `vms`. The validation SHALL apply whether or not `enable_flexible_gpus` is true.

#### Scenario: Rejected role
- **WHEN** `flexible_gpus = { compute = { model_name = "nvidia-p100", vm_role = "missing" } }` and `vms` has no `missing` key
- **THEN** the plan fails with "Each flexible GPU's vm_role must reference a valid key in the vms variable."

### Requirement: Flexible GPU outputs
`flexible_gpu_ids` SHALL map each GPU key to its id and `flexible_gpu_details` SHALL map it to an object with `flexible_gpu_id`, `model_name`, `state`, `subregion_name`, `vm_id` and `delete_on_vm_deletion`.

#### Scenario: Output keys
- **WHEN** one GPU entry `compute` targets role `backend` of count 1
- **THEN** both outputs have the key `compute:backend-0`

### Requirement: Flexible GPU tags not applied
The `tags` field of a `flexible_gpus` entry SHALL be accepted but not applied, because the provider's flexible GPU resource has no tags; its description SHALL say so.

#### Scenario: Tags on a GPU entry
- **WHEN** an entry sets `tags = { Team = "ml" }`
- **THEN** the plan succeeds and the flexible GPU carries no tags
