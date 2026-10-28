## Decisions

- **Volume subregion**: `locals.volume_instances.subregion_name` keeps only
  `vol.subregion_name` or the role subregion (may be null); the resource uses
  `coalesce(each.value.subregion_name, outscale_vm.this[each.value.vm_key].placement_subregion_name)`,
  the same mechanism as `outscale_flexible_gpu.this`. No perpetual diff: the VM reports its
  subregion after creation, and a volume with an explicit or role subregion keeps the same
  value as before.
- **Security group keys**: `precondition` in `outscale_vm.this` checking
  `var.enable_security_groups && contains(keys(var.security_groups), key)` for every key.
  Variable validation cannot be used while `required_version` is `>= 1.5`.
- **Flexible GPU tags**: provider 1.8 `outscale_flexible_gpu` exposes no tags; the local is
  removed. A future major should drop `flexible_gpus[*].tags`.
- No provider, backend or CLI change; no `moved` block needed (no address changes).
