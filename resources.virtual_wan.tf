locals {
  // Create Boolean for VWAN is a simple Count based on value fed in.
  create_vwan = (var.network_topology_details.network_type == "Vwan" ? var.network_topology_details.create_vwan : false) // Check to see if we need a vpn gw, if vnet is Vnet-gw then yes - but check the override flag (create_vnet_gw) regardless
}

module "vwan" {
  source  = "Azure/avm-ptn-alz-connectivity-virtual-wan/azurerm"
  version = "0.16.1"

  for_each = local.create_vwan ? var.virtual_wans : {}

  enable_telemetry = false

  virtual_wan_settings = {
    enabled_resources = {
      ddos_protection_plan = false
    }

    virtual_wan = {
      name                           = module.naming["virtual_wan-${each.value.location}-${each.value.resource_name}"].name
      location                       = each.value.location
      resource_group_name            = element(split("/", var.resource_groups["${each.value.location}-network"]), -1)
      type                           = "Standard"
      allow_branch_to_branch_traffic = true
      disable_vpn_encryption         = false
      tags                           = each.value.tags
    }
  }

  virtual_hubs = {
    for region, hub in each.value.virtual_hubs : hub.resource_name => {

      enabled_resources = {
        firewall                              = try(hub.enabled_resources.firewall, false)
        firewall_policy                       = try(hub.enabled_resources.firewall_policy, false)
        bastion                               = try(hub.enabled_resources.bastion, false)
        private_dns_zones                     = try(hub.enabled_resources.private_dns_zones, false)
        private_dns_resolver                  = try(hub.enabled_resources.private_dns_resolver, false)
        sidecar_virtual_network               = try(hub.enabled_resources.sidecar_virtual_network, false)
        virtual_network_gateway_vpn           = length(hub.vpn_gw) > 0 ? true : false
        virtual_network_gateway_express_route = length(hub.er_gw) > 0 ? true : false
      }

      location          = hub.location
      default_parent_id = var.resource_groups["${each.value.location}-network"]

      hub = {
        name           = hub.resource_name
        address_prefix = hub.address_prefix
        tags           = each.value.tags
      }

      virtual_network_gateways = {
        express_route = length(hub.er_gw) > 0 ? {
          scale_units = hub.er_gw.scale_units
          tags        = try(hub.er_gw.tags, each.value.tags)
        } : {}

        vpn = length(hub.vpn_gw) > 0 ? {
          bgp_route_translation_for_nat_enabled = try(hub.vpn_gw.bgp_route_translation_for_nat_enabled, false)
          scale_units                           = hub.vpn_gw.scale_units
          tags                                  = try(hub.vpn_gw.tags, each.value.tags)
          bgp_settings = {
            asn = hub.vpn_gw.bgp_settings.asn
          }
        } : {}

      }
      tags = try(each.value.tags, {})
    }
  }
}
