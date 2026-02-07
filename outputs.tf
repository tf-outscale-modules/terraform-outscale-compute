########################################
# VM outputs
########################################

output "vm_ids" {
  description = "Map of VM IDs keyed by flattened VM key (role-index)"
  value       = { for k, v in outscale_vm.this : k => v.vm_id }
}

output "vm_private_ips" {
  description = "Map of VM private IPs keyed by flattened VM key"
  value       = { for k, v in outscale_vm.this : k => v.private_ip }
}

output "vm_public_ips" {
  description = "Map of VM public IPs keyed by flattened VM key (empty string if no public IP)"
  value       = { for k, v in outscale_vm.this : k => v.public_ip }
}

output "vm_details" {
  description = "Map of VM details including ID, private IP, public IP, state, and type"
  value = { for k, v in outscale_vm.this : k => {
    vm_id      = v.vm_id
    private_ip = v.private_ip
    public_ip  = v.public_ip
    state      = v.state
    vm_type    = v.vm_type
  } }
}

########################################
# Security group outputs
########################################

output "security_group_ids" {
  description = "Map of security group IDs keyed by security group name"
  value       = { for k, v in outscale_security_group.this : k => v.security_group_id }
}

########################################
# Volume outputs
########################################

output "volume_ids" {
  description = "Map of volume IDs keyed by compound key (vm_key:vol_key)"
  value       = { for k, v in outscale_volume.this : k => v.volume_id }
}

output "volume_link_states" {
  description = "Map of volume link states keyed by compound key (vm_key:vol_key)"
  value       = { for k, v in outscale_volume_link.this : k => v.state }
}

########################################
# Public IP outputs
########################################

output "public_ip_ids" {
  description = "Map of public IP allocation IDs keyed by VM key"
  value       = { for k, v in outscale_public_ip.this : k => v.public_ip_id }
}

output "public_ips" {
  description = "Map of public IP addresses keyed by VM key"
  value       = { for k, v in outscale_public_ip.this : k => v.public_ip }
}

########################################
# Keypair outputs
########################################

output "keypair_id" {
  description = "ID of the created keypair (null if keypair creation is disabled)"
  value       = var.enable_keypair ? outscale_keypair.this[0].keypair_id : null
}

output "keypair_name" {
  description = "Name of the created keypair (null if keypair creation is disabled)"
  value       = var.enable_keypair ? outscale_keypair.this[0].keypair_name : null
}

output "keypair_fingerprint" {
  description = "Fingerprint of the created keypair (null if keypair creation is disabled)"
  value       = var.enable_keypair ? outscale_keypair.this[0].keypair_fingerprint : null
  sensitive   = true
}

########################################
# Flexible GPU outputs
########################################

output "flexible_gpu_ids" {
  description = "Map of flexible GPU IDs keyed by compound key (gpu_key:vm_key)"
  value       = { for k, v in outscale_flexible_gpu.this : k => v.flexible_gpu_id }
}

output "flexible_gpu_details" {
  description = "Map of flexible GPU details keyed by compound key (gpu_key:vm_key)"
  value = { for k, v in outscale_flexible_gpu.this : k => {
    flexible_gpu_id       = v.flexible_gpu_id
    model_name            = v.model_name
    state                 = v.state
    subregion_name        = v.subregion_name
    vm_id                 = v.vm_id
    delete_on_vm_deletion = v.delete_on_vm_deletion
  } }
}
