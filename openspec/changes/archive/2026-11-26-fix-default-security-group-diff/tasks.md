# Tasks

## 1. Fix and unit tests

- [x] 1.1 In `main.tf`, set `outscale_vm.this.security_group_ids` to the concatenated list when it is non-empty and to `null` otherwise (no new variable, no `dynamic` block, no `ignore_changes`). Verify: `tofu validate` passes.
- [x] 1.2 In `variables.tf`, extend the `vms` description (or the field comment) to say that leaving both `security_group_ids` and `security_group_keys` empty keeps the Net's default security group, and that removing the last listed group requires listing its replacement. Verify: `tflint --recursive` reports nothing and the README tables pick it up after `pre-commit run -a`.
- [x] 1.3 In `tests/main.tftest.hcl`, add a run for a role with no security group asserting `has_security_groups` is false (so no list is sent; the planned attribute itself is unknown), and a run asserting a role with `security_group_ids` plans exactly those groups. Verify: `tofu test` passes.
- [x] 1.4 Add the new run to `TESTING.md`. Verify: the run name appears in the file.

## 2. Local checks

- [x] 2.1 Delete the gitignored `.terraform.lock.hcl`, then run `tofu fmt -recursive`, `tofu init -backend=false && tofu validate`, `tflint --recursive`, `tofu test`, `mise run test:examples`, `pre-commit run -a` (twice) and `mise run spec-validate`. Verify: all exit 0 and the README provider row still reads `~> 1.8`.

## 3. Live verification

- [x] 3.1 On the test account through `/tmp/upg-test/osc-run.sh` (rules in `/tmp/upg-test/RULES.md`): apply one `tinav5.c1r1p1` VM role without any security group in a throw-away Net, then `tofu plan -detailed-exitcode`. Verify: exit 0 (the v1.3.0 behaviour gave exit 2), then destroy with no leftovers. Result: second plan exit 0 with the Net default group `sg-cbf48d8a` attached; the same state planned with v1.3.0 exits 2 (`- "sg-cbf48d8a"`); 3 resources destroyed, no leftover.

## 4. Delivery

- [x] 4.1 Commit on `fix/default-security-group-diff` with the subject `Fix the perpetual diff on VMs that list no security group` (CHANGELOG line; git-cliff generates `CHANGELOG.md`). Verify: `git log -1 --format=%s` shows it.

## Workflow follow-up

- Archive with `/openspec-archive-change` in the same branch, regenerate the CHANGELOG for v1.3.1, open the MR into `develop`, merge only on a green pipeline, then release v1.3.1 (`develop` to `main`, annotated tag).
