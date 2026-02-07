# Security

## SSH Keypair

- The `keypair_public_key` variable is marked as `sensitive = true`
- Never hardcode SSH keys in Terraform files or commit them to version control
- Provide keys via environment variables (`TF_VAR_keypair_public_key`) or encrypted tfvars
- Rotate keypairs regularly and revoke access for departed team members

## Deletion Protection

- Use the `deletion_protection` option on VM roles containing critical workloads
- This prevents accidental destruction via `terraform destroy` or plan changes
- Always review `terraform plan` output before applying changes to production

## Security Groups

- Security groups are created with **no default rules** — all traffic is denied until you explicitly add rules
- Avoid using `0.0.0.0/0` for SSH (port 22) or RDP (port 3389) in production
- Use specific CIDR ranges or security group member references for inbound rules
- Review security group rules regularly and remove unused entries

## State Encryption

- Terraform state files may contain sensitive values (IPs, keypair references, etc.)
- Always use encrypted remote backends (S3 with encryption, etc.)
- Restrict access to state storage using IAM policies
- Never commit `.tfstate` or `.tfstate.backup` files to version control

## Outscale API Credentials

- Set `OSC_ACCESS_KEY` and `OSC_SECRET_KEY` as environment variables — never in `.tf` files
- In CI/CD, use masked and protected variables for Outscale API credentials
- Rotate access keys regularly (at least every 90 days)
- Use separate access keys per environment (dev/staging/prod) with least-privilege IAM policies
- The `outscale` provider reads credentials from environment variables by default — no configuration needed in code

## Secrets Management

- Use `mise.local.toml` (gitignored) for local API credentials
- In CI/CD, use protected variables for Outscale access keys
- Consider using a secrets manager (HashiCorp Vault, SOPS) for production credentials
- The `.gitignore` excludes `*.key`, `*.pem`, and `secrets.auto.tfvars` by default

## Input Validation

- `project_name` is validated to only allow lowercase alphanumeric characters and hyphens
- `environment` is restricted to `dev`, `staging`, or `prod`
- VM `count` must be at least 1 per role
- `keypair_public_key` is enforced as required when `enable_keypair` is true (via lifecycle precondition)
