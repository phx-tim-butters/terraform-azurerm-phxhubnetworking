locals {
  // Create the VPG and LGW resource maps for creation. Only create if the hub_networking_details.network_type is Vnet-gw and the create_gateways flag is set to true. Otherwise, return an empty map.

  local_network_gateways = var.network_topology_details.network_type == "Vnet-gw" ? (var.network_topology_details.create_gateways ?
    { for k, v in var.local_network_gateways :
      k =>
      merge(v, {
        name       = module.naming["local_network_gateway-${v.location}-${v.resource_name}"].name
        connection = merge(v.connection, { shared_key = v.connection.generate_psk ? random_password.lgw[v.name].result : v.connection.shared_key })
      })
    }
  : {}) : {}

  virtual_network_gateways = var.network_topology_details.network_type == "Vnet-gw" ? (var.network_topology_details.create_gateways ?
    { for k, v in var.virtual_network_gateways :
      k =>
      merge(v, {
        name              = module.naming["virtual_network_gateway-${v.location}-${v.resource_name}"].name
        ip_configurations = v.active_active_enabled ? (length(try(v.vpn_point_to_site, {})) > 0 ? 3 : 2) : (length(try(v.vpn_point_to_site, {})) > 0 ? 2 : 1)
      })
    }
  : {}) : {}
}

# Create any PSK as required
resource "random_password" "lgw" {
  for_each = { for lgw in var.local_network_gateways : lgw.name => lgw if lgw.connection.generate_psk }

  length = 32
}

# Store PSK in Deployment Keyvault
resource "azurerm_key_vault_secret" "lgw" {
  for_each = { for lgw in var.local_network_gateways : lgw.name => lgw if lgw.connection.generate_psk }

  name         = "lgw-psk-${each.value.location}-${each.value.name}"
  key_vault_id = var.deployment_key_vault_id
  value        = random_password.lgw[each.key].result
}

module "virtual_network_gateway" {
  source   = "Azure/avm-ptn-alz-connectivity-hub-and-spoke-vnet/azurerm//modules/virtual-network-gateway"
  version  = "0.17.3"
  for_each = local.virtual_network_gateways

  enable_telemetry = false

  parent_id                         = var.resource_groups["${each.value.location}-network"]
  virtual_network_gateway_subnet_id = "${var.hub_virtual_networks["${each.value.location}-hub"]}/subnets/GatewaySubnet"
  subnet_creation_enabled           = false
  location                          = each.value.location
  name                              = each.value.name
  sku                               = each.value.sku_size
  vpn_generation                    = each.value.generation
  type                              = each.value.type
  vpn_active_active_enabled         = each.value.active_active_enabled
  vpn_bgp_enabled                   = each.value.enable_bgp
  vpn_bgp_settings                  = each.value.bgp_settings

  tags = each.value.tags

  vpn_point_to_site = try(each.value.vpn_point_to_site, null)

  local_network_gateways = { for k, v in local.local_network_gateways : k => v if v.vpn_gateway_key == each.key }

  ip_configurations = { for ip_configuration in range(each.value.ip_configurations) :
    ip_configuration => {
      ip_configuration_name         = "PIP-${each.value.name}-0${ip_configuration + 1}"
      apipa_addresses               = null
      private_ip_address_allocation = "Dynamic"
      public_ip = {
        name              = "pip-${each.value.name}-0${ip_configuration + 1}"
        allocation_method = "Static"
        sku               = "Standard"
        tags              = null
        zones             = each.value.zones
      }
    }
  }
}
