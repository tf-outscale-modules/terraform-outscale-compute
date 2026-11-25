# Design

## Context

The module flattens roles into `local.vm_instances` and volumes into `local.volume_instances`; security groups are used straight from `var.security_groups`. Optional role fields such as `tpm_enabled` are `optional(bool)` (null default) and passed directly, so an unset field is omitted from the request. This change reuses that pattern. See proposal.md - Why.

## Goals / Non-Goals

**Goals:**
- Expose three existing provider arguments as opt-in attributes with a `null` default.
- Keep existing consumers' plans unchanged and the second plan empty.

**Non-Goals:**
- Multi-NIC (`primary_nic`, `nics`), `private_ips`, `get_admin_password`, `performance`, `bsu_optimized`, `security_group_names`, `placement_tenancy`, `nested_virtualization`, `state`.
- Any provider pin change, new output, new resource or `moved` block.

## Decisions

### Arguments, provider version and replacement impact
Verified with `tofu providers schema -json` (1.8.0 and 1.9.0 identical) and the 1.8.0 provider source.

| Resource argument | Introduced | Type | Schema | Effect of changing it on an existing object |
| --- | --- | --- | --- | --- |
| `outscale_security_group.remove_default_outbound_rule` | at or before 1.8.0 (present in 1.8.0) | bool | optional, computed, static default | **Forces replacement** (`RequiresReplace`) |
| `outscale_volume.termination_snapshot_name` | at or before 1.8.0 | string | optional | In-place, no replacement |
| `outscale_vm.is_source_dest_checked` | at or before 1.8.0 | bool | optional, computed | In-place update, no restart |

Provider 1.8.0 is the first version this module supports (`~> 1.8`), so the arguments are available to every supported consumer. The exact introduction release was not checked; the pin does not move either way.

### Opt-in with `null`, argument omitted
Each attribute is `optional(<type>)` without a default (`terraform-variables`: `null` means provider default, no invented default). The module passes the value straight to the resource; `null` leaves the argument unset. For the VM and security-group arguments the provider default (`false`, or the server-computed value) then applies and equals the state of every existing object, so the first plan after upgrading is empty and no perpetual diff appears (`terraform-code-style`, no perpetual diff). The default is deliberately not `true` for `remove_default_outbound_rule`: flipping it would force replacement of every existing group and cut egress silently (`quality-security`, no silent weakening); opting in is explicit and visible in review.

Alternative rejected: a module-wide `enable_...` toggle. Per-group and per-role values match how every other field is configured and avoid a second mechanism.

### State migration
- Upgrading with the attributes unset: no diff, nothing to migrate, no `moved` block.
- Setting `remove_default_outbound_rule = true` on an existing group **forces its replacement**. Live test (provider 1.9.0): the apply fails with "The Security Group is the unique Security Group of the following VMs" when the group is the only one of a VM, because the provider destroys before creating and the group name must stay unique. Nothing is lost on that failure, but the supported ways are to set the flag when the group is first created, or to attach the VMs to another group first. The variable comment, README and MR note say so.
- Only the security group flag replaces an object; the volume and VM changes are in place and interrupt nothing.

### Plumbing
- `variables.tf`: add the attributes to the `vms` role object, the `volumes` entry object and the `security_groups` entry object, with a short trailing comment like the existing `tpm_enabled` fields. Attribute names mirror the provider argument names, as the existing `deletion_protection` and `tpm_enabled` do, so the `enable_`/`is_` boolean prefix rule of `terraform-variables` (which targets top-level variables) is not applied to them; no DEVIATION comment is needed.
- `locals.tf`: add `is_source_dest_checked` to `vm_instances` and `termination_snapshot_name` to `volume_instances`.
- `main.tf`: pass the values as plain arguments, placed per `terraform-code-style` attribute ordering. No `dynamic` block, no provider or backend block, no CLI call.

### Validation
- `termination_snapshot_name`: no length or charset rule is documented by the provider schema or source, so none is added (nothing invented). The API validates it at apply time.
- `remove_default_outbound_rule` and `is_source_dest_checked`: bool types already constrain the input.

### Security posture
`remove_default_outbound_rule = true` with no `outbound_rules` leaves a group with no egress, which is the secure but possibly surprising result; it is a scenario in the spec and is shown in the example together with explicit outbound rules (`terraform-security` network defaults, `quality-security` least privilege). `is_source_dest_checked = false` weakens a network control and is therefore never defaulted. No secret is involved, so `terraform-security` write-only arguments do not apply.

## Risks / Trade-offs

- [Replacement of a security group when the flag is turned on] → documented in the description, README and MR note; applies only on opt-in.
- [Termination snapshots persist after destroy and cost storage] → documented; the snapshot sits outside Terraform state, so callers clean it up themselves.
- [Plan-mode tests cannot show server-computed values for unset arguments (`is_source_dest_checked` is computed, so unknown in a plan)] → tests assert the set cases and that the unset case stays unknown rather than a module-invented value.

## Migration Plan

Release as a minor version. No action for existing consumers. Rollback: remove the attribute from the caller; for a security group this replaces it again.
