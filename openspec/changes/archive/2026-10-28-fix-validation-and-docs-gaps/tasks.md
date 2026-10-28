## 1. Code

- [x] 1.1 Remove the dead `tags` from `fgpu_instances`; update the `flexible_gpus` description
- [x] 1.2 Volume subregion falls back to the VM subregion
- [x] 1.3 Precondition on `outscale_vm.this` for `security_group_keys`
- [x] 1.4 Fix the `security_group_ids` output description

## 2. Documentation and tests

- [x] 2.1 README: remove the wrong `deletion_protection` limitation
- [x] 2.2 Tests in `tests/main.tftest.hcl`: unknown key, disabled groups, volume without subregion, happy path with keys
- [x] 2.3 No example input changes; `examples/complete` is unchanged and still validates
- [x] 2.4 `tofu fmt`, `tofu validate`, `tofu test`, `tflint`, `pre-commit run -a`, `openspec validate --all --strict`
