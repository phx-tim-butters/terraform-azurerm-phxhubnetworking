variable "default_location" {
  type        = string
  description = "Default location for resources if not explicitly defined"
}

variable "templated_locations" {
  type        = list(string)
  description = "List of locations to deploy templated resources to"
  default     = []
}

variable "network_topology_details" {
  description = "Network Details for the environment"
  type = object({
    network_type                  = optional(string, "")
    create_gateways               = optional(bool, false)
    create_vwan                   = optional(bool, false)
    hub_peering_enabled           = optional(bool, true)
    hub_id                        = optional(map(string), {})
    vwan_hub_id                   = optional(map(string), {})
    vwan_routing_intent_enabled   = optional(bool, false)
    bastion_subnet_address_spaces = optional(list(string), [])
  })
  default = {
    network_type                  = ""
    create_gateways               = false
    create_vwan                   = false
    hub_id                        = {}
    vwan_hub_id                   = {}
    vwan_routing_intent_enabled   = false
    bastion_subnet_address_spaces = []
  }
}

variable "resource_groups" {
  description = "Map of already provisioned resource groups for connectivity"
  type        = map(string)
}

variable "virtual_networks" {
  description = "Map of already provisioned virtual networks for connectivity that, as part of this module call, need to be connected to either the vwan or the hub network (after gateway creation)"
  type        = map(string)
  default     = {}
}

variable "virtual_wans" {
  description = "Map of virtual WANs for connectivity"
  type        = map(any)
  default     = {}
}

variable "virtual_network_gateways" {
  type    = map(any)
  default = {}
}

variable "local_network_gateways" {
  type    = map(any)
  default = {}
}

variable "deployment_key_vault_id" {
  description = "Key Vault ID for storing deployment secrets"
  type        = string
  default     = ""
}
