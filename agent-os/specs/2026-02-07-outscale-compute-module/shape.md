# Outscale Compute Module — Shaping Notes

## Scope

**In scope:**
- VM provisioning via role-based map (`var.vms`)
- Security group creation (optional, via `enable_security_groups`)
- Volume creation and attachment (nested in VM roles)
- Public IP allocation and linking (per-role toggle)
- Keypair creation (optional, via `enable_keypair`)
- Consistent naming: `{project_name}-{environment}-{role}-{index}`
- Common tags pattern with merge support

**Out of scope:**
- Networking (nets, subnets, route tables) — use networking module
- Load balancers
- Auto-scaling
- User data / cloud-init (can be passed but not managed)
- Backup policies

## Key Decisions

### VM Flattening Pattern
Users provide a map of roles with counts. The module flattens this into individual VM instances:
```
{ frontend = { count = 3 }, backend = { count = 2 } }
→ { "frontend-0", "frontend-1", "frontend-2", "backend-0", "backend-1" }
```
This gives stable resource addresses — removing `frontend-2` doesn't affect `backend-0`.

### Security Group Architecture
Two input paths:
1. `security_group_ids` — pre-existing SG IDs from outside the module
2. `security_group_keys` — references to SGs created by this module via `var.security_groups`

This avoids circular dependencies where VMs reference SGs that reference VMs.

### Volume Coupling
Volumes are defined inside each VM role, then flattened with compound keys like `"backend-0:data"`. The subregion is auto-derived from the parent VM's placement.

## Context
- Provider: Outscale (3DS Outscale cloud, EU sovereign)
- Provider source: `outscale/outscale`
- Similar to AWS but with different resource names and API
- Target users: teams deploying on Outscale cloud infrastructure
