# External References

## Networking Module
- Source: `https://github.com/tf-outscale-modules/terraform-outscale-networking`
- Creates: nets, subnets, route tables, internet services
- Used in: `examples/complete/` to provision networking before VMs
- Not a module dependency — only referenced in examples

## Storage Module
- Source: `https://github.com/tf-outscale-modules/terraform-outscale-storage`
- Creates: volumes, snapshots
- Used in: examples for reference; this compute module handles its own volume creation
- Not a module dependency — only referenced for patterns

## Outscale Provider
- Source: `outscale/outscale`
- Registry: `registry.terraform.io/outscale/outscale`
- Version constraint: `~> 1.0`
- Key resources used:
  - `outscale_vm` — virtual machines
  - `outscale_security_group` — security groups
  - `outscale_security_group_rule` — SG rules
  - `outscale_volume` — block storage volumes
  - `outscale_volume_link` — attach volumes to VMs
  - `outscale_public_ip` — elastic IPs
  - `outscale_public_ip_link` — associate public IPs to VMs
  - `outscale_keypair` — SSH key pairs
