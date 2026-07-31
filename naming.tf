locals {
  resources = merge(
    # Construct Namings for Gateways
    { for k, v in var.virtual_network_gateways : "virtual_network_gateway-${v.location}-${v.resource_name}" => merge(
      v
      ,
      {
        resource_type             = "virtual_network_gateway"
        resource_group_short_name = "${v.location}-network"
      })
    }
    ,
    { for k, v in var.local_network_gateways : "local_network_gateway-${v.location}-${v.resource_name}" => merge(
      v
      ,
      {
        resource_type             = "local_network_gateway"
        resource_group_short_name = "${v.location}-network"
      })
    }
    ,
    { for k, v in var.virtual_wans : "virtual_wan-${v.location}-${v.resource_name}" => merge(
      v
      ,
      {
        resource_type             = "virtual_wan"
        resource_group_short_name = "${v.location}-network"
      })
    }
  )
}

# For generated list of Resources within this module, generate all names
module "naming" {
  source   = "phx-tim-butters/phxnaming/azurerm"
  version  = "0.1.4"
  for_each = local.resources

  archetype             = try(each.value.workload, var.archetype)
  workload_abbreviation = try(each.value.workload, var.workload_abbreviation)
  org_abbreviation      = var.org_abbreviation
  env_abbreviation      = try(each.value.environment, var.deploy_abbreviation)
  structure             = try(each.value.structure, var.structure)
  deploy_abbreviation   = var.deploy_abbreviation
  location              = each.value.location

  resource_type           = each.value.resource_type
  resource_name           = each.value.resource_name
  resource_name_overwrite = try(each.value.resource_name_overwrite, false)

  resource_group_name           = each.value.resource_group_short_name
  resource_group_name_overwrite = try(each.value.resource_group_name_overwrite, false)

  case_option = try(each.value.case_option, "lower")
}
