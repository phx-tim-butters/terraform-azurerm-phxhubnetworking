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

  resource_group_name                 = "hub_networking-example"
  hub_virtual_network_name            = "hub_networking-example-hub"
  spoke_virtual_network_name          = "hub_networking-example-spoke"
  hub_virtual_network_address_space   = "10.0.0.0/16"
  spoke_virtual_network_address_space = "10.1.0.0/16"

  tags = {}

  virtual_network_gateways = {
    uksouth = {
      type                  = "Vpn"
      address_space         = "10.0.1.0/24"
      resource_name         = "01"
      location              = "uksouth"
      generation            = "Generation1"
      sku_size              = "VpnGw1AZ"
      enable_bgp            = false
      active_active_enabled = true
      bgp_settings = {
        asn = 65515
      }
      zones = [1, 2, 3]
      tags  = {}
    }
  }

  local_network_gateways = {
    OnPrem01 = {
      resource_name   = "OnPrem01"
      vpn_gateway_key = "uksouth"
      location        = "uksouth"
      address_space = [
        "192.168.50.0/24"
      ]
      bgp_settings = {
        asn                 = 65001
        bgp_peering_address = "192.168.10.1"
      }
      //gateway_address = "139.153.0.10"
      gateway_fqdn = "vpn.org.org"
      connection = {
        resource_name       = "uksouth_to_onPrem01"
        type                = "IPsec"
        dpd_timeout_seconds = 45
        generate_psk        = false
        shared_key          = "P@ssw0rd1234"
        enable_bgp          = false
        ipsec_policy = {
          dh_group         = "DHGroup14"
          ike_encryption   = "AES256"
          ike_integrity    = "SHA256"
          ipsec_encryption = "AES256"
          ipsec_integrity  = "SHA256"
          pfs_group        = "PFS2048"
          sa_lifetime      = "27000"
        }
      }
    }
  }
}

resource "azurerm_resource_group" "example" {
  name     = local.resource_group_name
  location = local.default_location

  tags = local.tags
}

resource "azurerm_virtual_network" "example_hub" {
  name                = local.hub_virtual_network_name
  location            = local.default_location
  resource_group_name = azurerm_resource_group.example.name

  address_space = [local.hub_virtual_network_address_space]

  tags = local.tags
}

resource "azurerm_virtual_network" "example_spoke" {
  name                = local.spoke_virtual_network_name
  location            = local.default_location
  resource_group_name = azurerm_resource_group.example.name

  address_space = [local.spoke_virtual_network_address_space]

  tags = local.tags
}

resource "azurerm_subnet" "example_hub_gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example_hub.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "example_spoke" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example_spoke.name
  address_prefixes     = ["10.1.0.0/24"]
}

module "hub_networking" {
  source = "../../"

  org_abbreviation      = local.org_abbreviation
  structure             = local.structure
  workload_abbreviation = local.workload_abbreviation

  default_location = local.default_location

  network_topology_details = {
    create_gateways = true
    network_type    = "Vnet-gw"
    hub_id = {
      uksouth = azurerm_virtual_network.example_hub.id
    }
  }

  virtual_network_gateways = local.virtual_network_gateways
  local_network_gateways   = local.local_network_gateways

  resource_groups = {
    "uksouth-network" = azurerm_resource_group.example.id
  }

  virtual_networks = {
    "uksouth-hub" = {
      resource_id   = azurerm_virtual_network.example_hub.id
      location      = "uksouth"
      resource_name = "hub"
    },
    "uksouth-spoke" = {
      resource_id   = azurerm_virtual_network.example_spoke.id
      location      = "uksouth"
      resource_name = "spoke"
    }
  }
}
