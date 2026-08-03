output "virtual_wan_resource_ids" {
  value = { for k, v in module.vwan : k => try(v.resource_id, {}) if var.network_topology_details.create_vwan }
}

output "virtual_wan_hubs" {
  value = { for vwan_key, vwan in var.virtual_wans : vwan_key => { for hub_key, hub in vwan.virtual_hubs : hub.location => {
    id                     = module.vwan[vwan_key].virtual_hub_resource_ids[hub.resource_name]
    routing_intent_enabled = try(hub.routing_intent_enabled, false)
    }
    } if var.network_topology_details.create_vwan
  }
}

output "virtual_wan_hub_resource_names" {
  value = { for k, v in module.vwan : k => try(v.virtual_wan_resource_names, {}) if var.network_topology_details.create_vwan }
}
