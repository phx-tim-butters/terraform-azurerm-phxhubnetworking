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
    virtual_wan_hubs              = optional(map(any), {})
    bastion_subnet_address_spaces = optional(list(string), [])
  })
  default = {
    network_type                  = ""
    create_gateways               = false
    create_vwan                   = false
    hub_id                        = {}
    virtual_wan_hubs              = {}
    bastion_subnet_address_spaces = []
  }
}

variable "resource_groups" {
  description = "Map of already provisioned Resource Groups for use to create Network Hub connectivity resources within."
  type = map(object({
    resource_name = string
    location      = string
    resource_id   = string
  }))
}

variable "virtual_networks" {
  description = "Map of already provisioned Virtual Networks for use to create Network Hub connectivity resources within - and also to create the peering connections between the hub and spoke networks that MAY well be in the same archetype as the Connectivity"
  type = map(object({
    resource_name = string
    location      = string
    resource_id   = string
  }))
  default = {}
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
