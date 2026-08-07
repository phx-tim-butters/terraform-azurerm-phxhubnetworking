locals {

  hub_virtual_network_gateway_used = var.network_topology_details.network_type == "Vnet-gw" ? (var.network_topology_details.create_gateways ? true : false) : false

  hub_peering_map = local.create_vgw ? { for k, v in var.virtual_networks : k => {

    outbound_name             = "${k}-to-hub"
    inbound_name              = "hub-to-${k}"
    parent_id                 = v.resource_id
    remote_virtual_network_id = var.network_topology_details.hub_id[v.location]

    allow_forwarded_traffic      = true
    allow_virtual_network_access = true

  } if !strcontains(k, "hub") } : {}
}

module "peering_to_hub" {
  source   = "Azure/avm-res-network-virtualnetwork/azurerm//modules/peering"
  version  = var.module_avm_res_network_virtualnetwork_version
  for_each = local.hub_peering_map

  name                      = each.value.outbound_name
  parent_id                 = each.value.parent_id
  remote_virtual_network_id = each.value.remote_virtual_network_id

  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = local.hub_virtual_network_gateway_used
  allow_virtual_network_access = true

  create_reverse_peering = false

  depends_on = [
    module.virtual_network_gateway
  ]
}

module "peering_from_hub" {
  source   = "Azure/avm-res-network-virtualnetwork/azurerm//modules/peering"
  version  = var.module_avm_res_network_virtualnetwork_version
  for_each = local.hub_peering_map

  name                      = each.value.inbound_name
  parent_id                 = each.value.remote_virtual_network_id
  remote_virtual_network_id = each.value.parent_id

  allow_forwarded_traffic      = true
  allow_gateway_transit        = local.hub_virtual_network_gateway_used
  use_remote_gateways          = false
  allow_virtual_network_access = true

  create_reverse_peering = false

  depends_on = [
    module.virtual_network_gateway
  ]
}
