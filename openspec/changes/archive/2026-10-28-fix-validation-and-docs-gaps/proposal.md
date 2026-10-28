## Why

Writing the `adopt-openspec` baseline surfaced code and documentation gaps. Each one is
checked against the code and the provider schema (outscale/outscale 1.8).

## What Changes

| Issue | Decision | Breaking |
|-------|----------|----------|
| `fgpu_instances` builds `tags` but `outscale_flexible_gpu` has no tags argument or block (schema checked) | Code fix: drop the dead local. The `tags` field of `flexible_gpus` stays (removing it would be major); its description says it is not applied | No |
| `coalesce(vol.subregion_name, vm.placement_subregion_name)` fails at plan when both are null | Code fix: the volume falls back to the subregion of its VM (`outscale_vm.this[...].placement_subregion_name`, known after the VM exists), like flexible GPUs | No (only configs that failed) |
| An unknown `security_group_keys` entry, or `enable_security_groups = false`, gives an index error | Code fix: `precondition` on `outscale_vm.this` with a message naming the role. A precondition, not a variable validation, because validations may not read other variables before OpenTofu/Terraform 1.9 and the floor is 1.5 | No (only configs that failed) |
| `security_group_ids` output description says "keyed by security group name" | Doc fix: keyed by the `security_groups` map key (the spec already says so) | No |
| `flexible_gpus` validation applies when `enable_flexible_gpus` is false | Left: the baseline spec requires it, it catches typos in a disabled block, and relaxing it gains nothing | n/a |
| README says `deletion_protection` is not first-class, but the module passes it to `outscale_vm` | Doc fix: remove the wrong limitation | No |

Semver: **patch** (fixes and documentation; no input, output, default or address changes).

State: no new resource or secret; the volume `subregion_name` is unchanged for configs that
already worked.

## Impact

`main.tf`, `locals.tf`, `variables.tf`, `outputs.tf`, `README.md`, `tests/main.tftest.hcl`,
`examples/complete`, specs `volumes`, `vms`, `flexible-gpus`.
