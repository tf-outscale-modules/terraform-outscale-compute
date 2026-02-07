output "vm_ids" {
  description = "Map of all VM IDs"
  value       = module.compute.vm_ids
}

output "vm_private_ips" {
  description = "Map of all VM private IPs"
  value       = module.compute.vm_private_ips
}

output "vm_public_ips" {
  description = "Map of all VM public IPs"
  value       = module.compute.vm_public_ips
}

output "vm_details" {
  description = "Detailed VM information"
  value       = module.compute.vm_details
}

output "security_group_ids" {
  description = "Map of security group IDs"
  value       = module.compute.security_group_ids
}

output "volume_ids" {
  description = "Map of volume IDs"
  value       = module.compute.volume_ids
}

output "public_ip_ids" {
  description = "Map of public IP allocation IDs"
  value       = module.compute.public_ip_ids
}

output "public_ips" {
  description = "Map of public IP addresses"
  value       = module.compute.public_ips
}

output "keypair_name" {
  description = "Name of the created keypair"
  value       = module.compute.keypair_name
}

output "flexible_gpu_ids" {
  description = "Map of flexible GPU IDs"
  value       = module.compute.flexible_gpu_ids
}

output "flexible_gpu_details" {
  description = "Map of flexible GPU details"
  value       = module.compute.flexible_gpu_details
}
