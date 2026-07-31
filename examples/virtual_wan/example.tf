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

  resource_group_name           = "hub_networking_vwan-example"
  virtual_network_name          = "hub_networking_vwan-example"
  virtual_network_address_space = "10.0.0.0/16"

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
          address_prefix         = "10.0.0.0/23"
          location               = "uksouth"
          routing_intent_enabled = false
          er_gw                  = {}
          vpn_gw                 = {}
          tags                   = {}
        }
        canadaeast = {
          resource_name          = "hub-canadaeast"
          address_prefix         = "10.0.32.0/23"
          location               = "canadaeast"
          routing_intent_enabled = false
          er_gw                  = {}
          vpn_gw                 = {}
          tags                   = {}
        }
        italynorth = {
          resource_name          = "hub-italynorth"
          address_prefix         = "10.0.64.0/23"
          location               = "italynorth"
          routing_intent_enabled = false
          er_gw                  = {}
          vpn_gw                 = {}
          tags                   = {}
        }
      }

      tags = {
      }
    }
  }
}

resource "azurerm_resource_group" "example" {
  name     = local.resource_group_name
  location = local.default_location

  tags = local.tags
}

module "hub_networking" {
  source = "../../"

  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id

  org_abbreviation      = local.org_abbreviation
  structure             = local.structure
  workload_abbreviation = local.workload_abbreviation

  default_location = local.default_location

  network_topology_details = {
    create_gateways = true
    create_vwan     = true
    network_type    = "Vwan"
  }

  virtual_wans = local.virtual_wans

  resource_groups = {
    "uksouth-network" = azurerm_resource_group.example.id
  }

  hub_virtual_networks = {
  }

  depends_on = [
    azurerm_resource_group.example
  ]
}
