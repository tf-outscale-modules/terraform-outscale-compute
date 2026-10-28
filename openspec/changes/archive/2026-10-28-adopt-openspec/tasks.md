# Tasks

## 1. Remove legacy planning tooling
- [x] 1.1 Remove `agent-os/` and `.claude/commands/agent-os/`
- [x] 1.2 Remove the legacy `.github/prompts/opsx-*.prompt.md` files
- [x] 1.3 Check that no live reference to Agent OS remains (README, TESTING.md, docs; `CHANGELOG.md` is history)

## 2. Configure OpenSpec
- [x] 2.1 Fill `openspec/config.yaml` (context, rules, operations) for outscale-compute
- [x] 2.2 Fill `AGENTS.md`; `CLAUDE.md` imports it
- [x] 2.3 Install the `openspec-*` skills for Claude Code and OpenCode
- [x] 2.4 Pin `openspec` and node in `mise.toml`; add `spec-validate` and `spec-setup` tasks and `scripts/openspec-setup.sh`
- [x] 2.5 Add the `validate:specs` CI job (`.gitlab/specs.yml`, `OPENSPEC_VERSION`)

## 3. Baseline specs
- [x] 3.1 Write delta specs for `module-contract`, `vms`, `security-groups`, `keypair`, `volumes`, `flexible-gpus` from the released code
- [x] 3.2 `openspec validate --all --strict` passes (same command as the `validate:specs` CI job)
- [x] 3.3 Archive the change so the main specs land in `openspec/specs/`

## 4. Documentation
- [x] 4.1 Add the OpenSpec workflow to the README "Contributing" section
- [x] 4.2 Run `pre-commit run` on the changed files
