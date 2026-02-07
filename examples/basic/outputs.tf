output "vm_ids" {
  description = "Map of VM IDs"
  value       = module.compute.vm_ids
}

output "vm_private_ips" {
  description = "Map of VM private IPs"
  value       = module.compute.vm_private_ips
}
