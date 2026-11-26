# Design

## Context

See proposal.md (Why). `outscale_vm.security_group_ids` is a `set(string)`, Optional and Computed in provider 1.8.0 and 1.9.0. `main.tf` always sets it to `concat(role.security_group_ids, [ids of role.security_group_keys])`, so a role with no group sends an empty set while the server reads back the Net's default group.

## Goals / Non-Goals

**Goals:**
- Empty second plan for roles without security groups, on new and existing state.
- No change for roles that list groups.

**Non-Goals:**
- Letting callers detach every security group (Outscale requires at least one on a VM in a Net).
- Changing the `vms` input type or defaults.

## Decisions

### Send `null` when the computed list is empty
`vm_instances` gains a boolean `has_security_groups` (either list non-empty) and the resource sends `security_group_ids = has_security_groups ? concat(...) : null`. Because the attribute is Computed, `null` means "keep what the server reports", which is the default group. The group lookup stays in the resource so an unknown `security_group_keys` entry still fails on the VM precondition; the boolean lives in the local so plan-mode tests can assert it (the planned attribute itself is unknown).

Alternatives considered:
- Look up the Net's default group with a data source and send it explicitly: an extra API read per plan, and it needs the Net id, which the module does not take (`quality-efficiency`).
- `lifecycle { ignore_changes = [security_group_ids] }`: would also hide real drift on roles that do list groups.

### Patch release
Per `terraform-versioning`, normalisation that removes a perpetual diff is a patch: v1.3.1.

## Risks / Trade-offs

- [A role that removes its last listed group keeps it instead of falling back to the default group] → With `null` the provider keeps the last server value. Documented in the `vms` description; the caller lists the replacement group (or the default group id) explicitly to move the VM.
- [Plan-mode tests cannot see the server-assigned value] → Unit test asserts the planned argument is unknown/omitted for an empty role and unchanged for a listed one; the empty second plan is proven on the real account (task 3).

## Migration Plan

No state migration: existing VMs without groups already have the default group in state; after upgrading, the next plan is empty instead of an in-place update. No `moved` block, no replacement. Rollback: pin v1.3.0 (the perpetual diff returns).
