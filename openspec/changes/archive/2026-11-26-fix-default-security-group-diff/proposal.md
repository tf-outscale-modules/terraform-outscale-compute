# Proposal

## Why

A VM role with neither `security_group_ids` nor `security_group_keys` never converges: the module sends `security_group_ids = []`, Outscale attaches the Net's default security group to the VM, and every later plan proposes to remove it. The live test of v1.3.0 on a real account reproduced it (second plan exit code 2 on the role `rtr-0`), which breaks the `terraform-code-style` rule "No perpetual diff".

## What Changes

- When a role lists no security group (both `security_group_ids` and `security_group_keys` empty), the module omits `security_group_ids` on `outscale_vm` (sends `null`) instead of sending `[]`, so the provider keeps the group the server assigned and the second plan is empty.
- Roles that list at least one group are unchanged: the VM is still attached to exactly `security_group_ids` followed by the groups of `security_group_keys`.
- Document in the `vms` input description that an empty list means "the Net's default security group", not "no security group" (a VM in a Net always has at least one).
- No input, output, default, type or resource address changes. **No breaking change.**

Semver classification (`terraform-versioning`): **patch** (normalisation that removes a perpetual diff), v1.3.0 to v1.3.1. Provider pin stays `~> 1.8`.

Inputs and outputs whose type, default or meaning changes: none. The meaning of an empty `security_group_ids`/`security_group_keys` is clarified, not changed: Outscale already attached the default group; the module now stops fighting it.

What lands in state: unchanged. `outscale_vm.security_group_ids` already stores the attached group ids (not secret); no new secret-bearing input, so `terraform-security` write-only rules do not apply.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `vms`: the "Security group attachment" requirement gains the default-group behaviour for a role that lists no security group.

## Impact

- Code: `main.tf` (`outscale_vm.this.security_group_ids`), `variables.tf` (description of `vms`), `tests/main.tftest.hcl`, `TESTING.md`, README (terraform-docs block via pre-commit).
- Existing state: VMs created without groups already hold the default group in state; after the upgrade the next plan is empty instead of an update. No replacement, no `moved` block.
- Standards applied: `terraform-code-style` (no perpetual diff), `terraform-versioning` (patch), `terraform-variables` (description), `quality-production-readiness` (idempotent, verified against the real account).
