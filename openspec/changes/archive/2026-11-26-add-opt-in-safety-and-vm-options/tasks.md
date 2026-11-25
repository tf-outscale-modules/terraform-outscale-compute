# Tasks

## 1. Inputs and plumbing

- [x] 1.1 In `variables.tf`, add `is_source_dest_checked = optional(bool)` to the `vms` role object, `termination_snapshot_name = optional(string)` to its `volumes` entry object and `remove_default_outbound_rule = optional(bool)` to the `security_groups` entry object, each with a one-line comment (replacement impact where it applies). Verify: `tofu validate` passes and `tflint --recursive` reports nothing.
- [x] 1.2 In `locals.tf`, pass `is_source_dest_checked` through `vm_instances` and `termination_snapshot_name` through `volume_instances`. Verify: `tofu validate` passes.
- [x] 1.3 In `main.tf`, set the three arguments on `outscale_security_group.this`, `outscale_volume.this` and `outscale_vm.this` (attribute ordering per `terraform-code-style`; no `dynamic` block, no `provider`/`backend`, no CLI call). Verify: `tofu validate` passes and an unchanged call still plans without diff.

## 2. Tests

- [x] 2.1 In `tests/main.tftest.hcl`, add a run asserting `remove_default_outbound_rule = true` is planned on the group and that a group that omits it keeps the provider default. Verify: `tofu test` passes.
- [x] 2.2 Add a run for a group with `remove_default_outbound_rule = true` and one outbound rule (only `web:outbound:0` exists) and one for `true` with no outbound rule (plan succeeds). Verify: `tofu test` passes.
- [x] 2.3 Add a run asserting `termination_snapshot_name` is planned on every volume of the entry and that an omitted value plans no snapshot name. Verify: `tofu test` passes.
- [x] 2.4 Add a run asserting `is_source_dest_checked = false` is planned on the role's VMs, and that a role omitting it leaves the value unknown (server-computed). Verify: `tofu test` passes.
- [x] 2.5 Update `TESTING.md` if it lists the test runs. Verify: every new run name appears in the file.

## 3. Example and docs

- [x] 3.1 Update `examples/complete/main.tf` to show the secure settings: one security group with `remove_default_outbound_rule = true` plus an explicit outbound rule (replace the "default outbound allow-all" note), a volume with `termination_snapshot_name`, and a role with `is_source_dest_checked` set. Verify: `mise run test:examples` passes.
- [x] 3.2 Update README prose outside `BEGIN_TF_DOCS` / `END_TF_DOCS` (features or notes) to mention the three options and that enabling `remove_default_outbound_rule` on an existing group replaces it. Verify: the text is present and the terraform-docs block is untouched by hand.
- [x] 3.3 Check `SECURITY.md`: no secret or state row is added (non-secret values only); add a line on the no-egress consequence only if it lists network defaults. Verify: `grep` shows the file is consistent with the change.

## 4. Verification and delivery

- [x] 4.1 Run `tofu fmt -recursive`, `tofu init -backend=false && tofu validate`, `tflint --recursive` and `tofu test`. Verify: all exit 0; report output as-is.
- [x] 4.2 Run `pre-commit run -a` so terraform-docs regenerates the README tables with the new attributes. Verify: exits 0 on a second run with no further diff.
- [x] 4.3 Run `mise run spec-validate`. Verify: exits 0.
- [ ] 4.4 Commit with a subject that reads as the CHANGELOG line, e.g. `Add opt-in security group egress removal, volume termination snapshot and VM source/destination check options` (git-cliff generates `CHANGELOG.md`; do not edit it). Verify: `git log -1 --format=%s` shows it. In the merge request note that enabling `remove_default_outbound_rule` on an existing group replaces it; nothing is breaking.
- [x] 4.5 Live test against the real account (2 VMs, provider 1.9.0): apply without the new attributes then with them, second plans empty, egress, termination snapshot and `is_source_dest_checked` verified, destroyed with no leftovers. Result: replacing an existing sole-group security group fails (documented in design.md, variables.tf and README).

## Workflow follow-up

- Archive with `/openspec-archive-change` after merge; confirm the commit subject reads as a CHANGELOG line and the terraform-docs block was regenerated.
