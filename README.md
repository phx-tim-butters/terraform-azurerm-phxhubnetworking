# terraform-azurerm-hubnetworking

Terraform module to provision hub networking components for an enterprise platform landing zone.

This module is a wrapper around Azure Verified Modules (AVM) and supports two mutually exclusive hub networking patterns:

- Virtual Network Gateway model (`Vnet-gw`)
- Virtual WAN model (`Vwan`)

The module is integrated with the Phoenix naming module (`phx-tim-butters/phxnaming/azurerm`) to ensure consistent naming across all deployed resources.

## Architecture Intent

Use this module when you want a consistent, enterprise-scale entry point for hub networking that:

- Aligns naming with organisational standards
- Chooses one hub connectivity pattern per deployment
- Delegates low-level implementation to maintained AVM modules
- Optionally generates and stores VPN pre-shared keys in Azure Key Vault

## Supported Deployment Modes

### 1. Virtual Network Gateway mode

Set `network_topology_details.network_type = "Vnet-gw"` and `network_topology_details.create_gateways = true`.

In this mode, the module:

- Creates one or more Azure Virtual Network Gateways
- Creates Local Network Gateways and connections
- Supports active-active and optional point-to-site gateway configuration
- Optionally generates PSKs and stores them in `deployment_key_vault_id`

### 2. Virtual WAN mode

Set `network_topology_details.network_type = "Vwan"` and `network_topology_details.create_vwan = true`.

In this mode, the module:

- Creates one or more Virtual WAN resources
- Creates one or more Virtual Hubs per Virtual WAN definition
- Optionally enables VPN and ExpressRoute gateway resources per hub

## Module Dependencies

This module wraps and orchestrates:

- `Azure/avm-ptn-alz-connectivity-hub-and-spoke-vnet/azurerm//modules/virtual-network-gateway` (`0.17.3`)
- `Azure/avm-ptn-alz-connectivity-virtual-wan/azurerm` (`0.16.1`)
- `phx-tim-butters/phxnaming/azurerm` (`0.1.4`)

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| azurerm | >= 4.0.0 |
| random | any |

## Providers

| Name | Version |
|------|---------|
| azurerm | >= 4.0.0 |
| random | any |

## Resources

| Name | Type |
|------|------|
| random_password.lgw | resource |
| azurerm_key_vault_secret.lgw | resource |
| module.naming | module |
| module.virtual_network_gateway | module |
| module.vwan | module |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| default_location | Default location for resources if not explicitly defined. | `string` | n/a | yes |
| templated_locations | List of locations to deploy templated resources to. | `list(string)` | `[]` | no |
| network_topology_details | Network topology settings controlling deployment mode and feature toggles. | `object({...})` | see variable default | no |
| resource_groups | Map of resource group resource IDs for connectivity (key pattern: `<location>-network`). | `map(string)` | n/a | yes |
| hub_virtual_networks | Map of hub VNet resource IDs (key pattern: `<location>-hub`). Required for `Vnet-gw` mode. | `map(string)` | `{}` | no |
| virtual_wans | Virtual WAN configuration map, including virtual hub definitions. Used in `Vwan` mode. | `map(any)` | `{}` | no |
| virtual_network_gateways | Virtual Network Gateway configuration map. Used in `Vnet-gw` mode. | `map(any)` | `{}` | no |
| local_network_gateways | Local Network Gateway and connection configuration map. Used in `Vnet-gw` mode. | `map(any)` | `{}` | no |
| deployment_key_vault_id | Key Vault resource ID used to store generated local gateway PSKs. Required only when `connection.generate_psk = true`. | `string` | `""` | no |
| structure | Naming structure pattern used by Phoenix naming module. | `string` | n/a | yes |
| environment | Environment identifier used in naming placeholders. | `string` | `""` | no |
| deploy_abbreviation | Deployment suffix used in naming output. | `string` | `""` | no |
| org_abbreviation | Organisation abbreviation used in naming placeholders. | `string` | n/a | yes |
| archetype | Archetype/workload type used in naming placeholders. | `string` | `""` | no |
| workload_abbreviation | Workload abbreviation used in naming placeholders. | `string` | `""` | no |
| resources | Optional explicit resource map for naming references. | `map(object({...}))` | `{}` | no |

## Outputs

No explicit outputs are currently defined by this module.

## Usage

### Virtual Network Gateway example

```hcl
module "hub_networking" {
  source = "phx-tim-butters/hubnetworking/azurerm"

  org_abbreviation      = "phxcp"
  structure             = "TYPE-ORG-REGION-WORK-NAME"
  workload_abbreviation = "con"
  default_location      = "uksouth"

  network_topology_details = {
    network_type    = "Vnet-gw"
    create_gateways = true
  }

  virtual_network_gateways = {
    uksouth = {
      type                  = "Vpn"
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
    onprem01 = {
      resource_name   = "OnPrem01"
      vpn_gateway_key = "uksouth"
      location        = "uksouth"
      address_space   = ["192.168.50.0/24"]
      gateway_fqdn    = "vpn.example.org"
      bgp_settings = {
        asn                 = 65001
        bgp_peering_address = "192.168.10.1"
      }
      connection = {
        resource_name       = "uksouth_to_onprem01"
        type                = "IPsec"
        dpd_timeout_seconds = 45
        generate_psk        = true
        shared_key          = ""
        enable_bgp          = false
      }
    }
  }

  resource_groups = {
    "uksouth-network" = azurerm_resource_group.hub.id
  }

  hub_virtual_networks = {
    "uksouth-hub" = azurerm_virtual_network.hub.id
  }

  deployment_key_vault_id = azurerm_key_vault.platform.id
}
```

### Virtual WAN example

```hcl
module "hub_networking" {
  source = "phx-tim-butters/hubnetworking/azurerm"

  org_abbreviation      = "phxcp"
  structure             = "TYPE-ORG-REGION-WORK-NAME"
  workload_abbreviation = "con"
  default_location      = "uksouth"

  network_topology_details = {
    network_type = "Vwan"
    create_vwan  = true
  }

  virtual_wans = {
    main = {
      resource_name = "01"
      location      = "uksouth"
      virtual_hubs = {
        uksouth = {
          resource_name  = "hub-uksouth"
          address_prefix = "10.0.0.0/23"
          location       = "uksouth"
          er_gw          = {}
          vpn_gw         = {}
          tags           = {}
        }
      }
      tags = {}
    }
  }

  resource_groups = {
    "uksouth-network" = azurerm_resource_group.hub.id
  }
}
```

## Important Behaviour Notes

- `network_topology_details.network_type` is case-sensitive and currently expects either `Vnet-gw` or `Vwan`.
- For VNet gateway deployments, the hub virtual network must contain a subnet named `GatewaySubnet`.
- `resource_groups` and `hub_virtual_networks` maps are referenced using derived keys. Ensure keys follow the expected naming patterns.
- If `connection.generate_psk = true`, `deployment_key_vault_id` must be provided and write access to Key Vault must exist.

## Examples

- Virtual Network Gateway: [examples/virtual_network_gateway/example.tf](examples/virtual_network_gateway/example.tf)
- Virtual WAN: [examples/virtual_wan/example.tf](examples/virtual_wan/example.tf)

## Publishing to Terraform Registry

Before publishing:

1. Ensure repository naming follows registry conventions.
2. Ensure version tags are pushed (for example, `v1.0.0`).
3. Verify this README and example configurations are up to date.
4. Confirm licence terms are correct for your intended distribution.
5. Run formatting and validation:

```bash
terraform fmt -recursive
terraform init
terraform validate
```

## Maintainer

Phoenix Software
