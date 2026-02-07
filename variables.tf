########################################
# Required variables
########################################

variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, or prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "vms" {
  description = "Map of VM role definitions. Each key is a role name (e.g., 'frontend', 'backend') with its configuration including count, image, type, networking, and optional volumes"
  type = map(object({
    count                    = number
    image_id                 = string
    vm_type                  = string
    subnet_id                = string
    keypair_name             = optional(string)
    security_group_ids       = optional(list(string), [])
    security_group_keys      = optional(list(string), [])
    placement_subregion_name = optional(string)
    enable_public_ip         = optional(bool, false)
    deletion_protection      = optional(bool, false)
    user_data                = optional(string)
    block_device_mappings = optional(list(object({
      device_name = string
      bsu = object({
        volume_size           = number
        volume_type           = optional(string, "gp2")
        iops                  = optional(number)
        snapshot_id           = optional(string)
        delete_on_vm_deletion = optional(bool, true)
      })
    })), [])
    volumes = optional(map(object({
      size           = number
      type           = optional(string, "gp2")
      iops           = optional(number)
      snapshot_id    = optional(string)
      device_name    = string
      subregion_name = optional(string)
      tags           = optional(map(string), {})
    })), {})
    tags = optional(map(string), {})
  }))
}

########################################
# Optional variables
########################################

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "enable_security_groups" {
  description = "Enable creation of security groups defined in the security_groups variable"
  type        = bool
  default     = false
}

variable "security_groups" {
  description = "Map of security groups to create when enable_security_groups is true. Keys are referenced by security_group_keys in VM definitions"
  type = map(object({
    description = string
    net_id      = string
    inbound_rules = optional(list(object({
      from_port_range                   = number
      to_port_range                     = number
      ip_protocol                       = string
      ip_range                          = optional(string)
      security_group_account_id_to_link = optional(string)
      security_group_name_to_link       = optional(string)
    })), [])
    outbound_rules = optional(list(object({
      from_port_range                   = number
      to_port_range                     = number
      ip_protocol                       = string
      ip_range                          = optional(string)
      security_group_account_id_to_link = optional(string)
      security_group_name_to_link       = optional(string)
    })), [])
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "enable_keypair" {
  description = "Enable creation of an SSH keypair"
  type        = bool
  default     = false
}

variable "keypair_name" {
  description = "Name for the SSH keypair (required when enable_keypair is true)"
  type        = string
  default     = null
}

variable "keypair_public_key" {
  description = "Public key material for the SSH keypair. Provide via environment variable or tfvars, never hardcode"
  type        = string
  sensitive   = true
  default     = null
}
