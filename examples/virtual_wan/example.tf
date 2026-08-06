terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
  }
}

variable "subscription_id" {
  type        = string
  description = "The subscription ID to use."
}

variable "tenant_id" {
  type        = string
  description = "The tenant ID to use."
}

provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

locals {
  ############### PRIMARY INFORMATION ###############

  default_location      = "uksouth" // set to null if you want to enforce locations to come from config 
  org_abbreviation      = "example"
  structure             = "TYPE-ORG-REGION-WORK-NAME"
  workload_abbreviation = "con"

  resource_group_name                            = "hub_networking_vwan-example"
  spoke_uksouth_virtual_network_name             = "hub_networking_vwan-example-spoke-uksouth"
  spoke_uksouth_virtual_network_address_space    = "10.1.2.0/24"
  spoke_canadaeast_virtual_network_name          = "hub_networking_vwan-example-spoke-canadaeast"
  spoke_canadaeast_virtual_network_address_space = "10.2.2.0/24"
  spoke_italynorth_virtual_network_name          = "hub_networking_vwan-example-spoke-italynorth"
  spoke_italynorth_virtual_network_address_space = "10.3.2.0/24"

  tags = {}

  virtual_wans = {
    main = {
      resource_name                  = "01"
      type                           = "Standard"
      allow_branch_to_branch_traffic = true
      location                       = "uksouth"

      virtual_hubs = {
        uksouth = {
          resource_name          = "hub-uksouth"
          address_prefix         = "10.1.0.0/23"
          location               = "uksouth"
          routing_intent_enabled = true
          er_gw                  = {}
          vpn_gw                 = {}
          tags                   = {}
        }
        canadaeast = {
          resource_name          = "hub-canadaeast"
          address_prefix         = "10.2.0.0/23"
          location               = "canadaeast"
          routing_intent_enabled = false
          er_gw                  = {}
          vpn_gw                 = {}
          tags                   = {}
        }
        italynorth = {
          resource_name          = "hub-italynorth"
          address_prefix         = "10.3.0.0/23"
          location               = "italynorth"
          routing_intent_enabled = false
          er_gw                  = {}
          vpn_gw                 = {}
          tags                   = {}
        }
      }

      tags = {}
    }
  }
}

resource "azurerm_resource_group" "example" {
  name     = local.resource_group_name
  location = local.default_location

  tags = local.tags
}

locals {
  virtual_networks = {
    uksouth = {
      name          = "hub_networking_vwan-example-spoke-uksouth"
      location      = "uksouth"
      address_space = "10.1.2.0/24"
    }
    canadaeast = {
      name          = "hub_networking_vwan-example-spoke-canadaeast"
      location      = "canadaeast"
      address_space = "10.2.2.0/24"
    }
    italynorth = {
      name          = "hub_networking_vwan-example-spoke-italynorth"
      location      = "italynorth"
      address_space = "10.3.2.0/24"
    }
  }
}

resource "azurerm_virtual_network" "example_spoke_uksouth" {
  name                = local.spoke_uksouth_virtual_network_name
  location            = "uksouth"
  resource_group_name = azurerm_resource_group.example.name

  address_space = [local.spoke_uksouth_virtual_network_address_space]

  tags = local.tags
}

resource "azurerm_virtual_network" "example_spoke_canadaeast" {
  name                = local.spoke_canadaeast_virtual_network_name
  location            = "canadaeast"
  resource_group_name = azurerm_resource_group.example.name

  address_space = [local.spoke_canadaeast_virtual_network_address_space]

  tags = local.tags
}

resource "azurerm_virtual_network" "example_spoke_italynorth" {
  name                = local.spoke_italynorth_virtual_network_name
  location            = "italynorth"
  resource_group_name = azurerm_resource_group.example.name

  address_space = [local.spoke_italynorth_virtual_network_address_space]

  tags = local.tags
}

module "hub_networking" {
  source = "../../"

  org_abbreviation      = local.org_abbreviation
  structure             = local.structure
  workload_abbreviation = local.workload_abbreviation

  default_location = local.default_location

  network_topology_details = {
    network_type    = "Vwan"
    create_gateways = true
    create_vwan     = true
  }

  virtual_wans = local.virtual_wans

  resource_groups = {
    "uksouth-network" = {
      resource_name = local.resource_group_name
      location      = "uksouth"
      resource_id   = azurerm_resource_group.example.id
    }
  }

  virtual_networks = {
    "uksouth-spoke" = {
      resource_name = local.spoke_uksouth_virtual_network_name
      location      = "uksouth"
      resource_id   = azurerm_virtual_network.example_spoke_uksouth.id
    }
    "canadaeast-spoke" = {
      resource_name = local.spoke_canadaeast_virtual_network_name
      location      = "canadaeast"
      resource_id   = azurerm_virtual_network.example_spoke_canadaeast.id
    }
    "italynorth-spoke" = {
      resource_name = local.spoke_italynorth_virtual_network_name
      location      = "italynorth"
      resource_id   = azurerm_virtual_network.example_spoke_italynorth.id
    }
  }

  depends_on = [
    azurerm_resource_group.example
  ]
}

output "virtual_wan_resource_ids" {
  value = try(module.hub_networking.virtual_wan_resource_ids, {})
}

output "virtual_wan_hubs" {
  value = try(module.hub_networking.virtual_wan_hubs, {})
}
