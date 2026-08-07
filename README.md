# terraform-azurerm-hubnetworking

Terraform module to provision hub networking components for an enterprise platform landing zone.

This module is a wrapper around Azure Verified Modules (AVM) and supports two mutually exclusive hub networking patterns:

- Virtual Network Gateway model (`Vnet-gw`)
- Virtual WAN model (`Vwan`)

The module is integrated with the Phoenix naming module (`phx-tim-butters/phxnaming/azurerm`) to ensure consistent naming across all deployed resources.

##  Intent

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

## Important Behaviour Notes

- `network_topology_details.network_type` is case-sensitive and currently expects either `Vnet-gw` or `Vwan`.
- For VNet gateway deployments, the hub virtual network must contain a subnet named `GatewaySubnet`.
- `resource_groups` and `hub_virtual_networks` maps are referenced using derived keys. Ensure keys follow the expected naming patterns.
- If `connection.generate_psk = true`, `deployment_key_vault_id` must be provided and write access to Key Vault must exist.

## Examples

- Virtual Network Gateway: [examples/virtual_network_gateway/example.tf](examples/virtual_network_gateway/example.tf)
- Virtual WAN: [examples/virtual_wan/example.tf](examples/virtual_wan/example.tf)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | > 4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | > 4 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_naming"></a> [naming](#module\_naming) | phx-tim-butters/phxnaming/azurerm | 0.1.4 |
| <a name="module_peering_from_hub"></a> [peering\_from\_hub](#module\_peering\_from\_hub) | Azure/avm-res-network-virtualnetwork/azurerm//modules/peering | 0.14.1 |
| <a name="module_peering_to_hub"></a> [peering\_to\_hub](#module\_peering\_to\_hub) | Azure/avm-res-network-virtualnetwork/azurerm//modules/peering | 0.14.1 |
| <a name="module_virtual_network_gateway"></a> [virtual\_network\_gateway](#module\_virtual\_network\_gateway) | Azure/avm-ptn-alz-connectivity-hub-and-spoke-vnet/azurerm//modules/virtual-network-gateway | 0.17.3 |
| <a name="module_vwan"></a> [vwan](#module\_vwan) | Azure/avm-ptn-alz-connectivity-virtual-wan/azurerm | 0.16.1 |

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault_secret.lgw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [random_password.lgw](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_archetype"></a> [archetype](#input\_archetype) | Archetype or workload type used in the ARCH placeholder (e.g., 'web', 'db', 'api'). Helps identify the purpose of the resource. | `string` | `""` | no |
| <a name="input_default_location"></a> [default\_location](#input\_default\_location) | Default location for resources if not explicitly defined | `string` | n/a | yes |
| <a name="input_deploy_abbreviation"></a> [deploy\_abbreviation](#input\_deploy\_abbreviation) | Deployment-specific suffix appended to the end of the resource name (e.g., '001', 'blue', 'green'). Useful for blue-green deployments or numbered instances. Optional. | `string` | `""` | no |
| <a name="input_deployment_key_vault_id"></a> [deployment\_key\_vault\_id](#input\_deployment\_key\_vault\_id) | Key Vault ID for storing deployment secrets | `string` | `""` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment identifier used in the ENV placeholder (e.g., 'prod', 'dev', 'test', 'uat', 'nonprod'). Optional, leave empty if not using ENV in your structure. | `string` | `""` | no |
| <a name="input_local_network_gateways"></a> [local\_network\_gateways](#input\_local\_network\_gateways) | n/a | `map(any)` | `{}` | no |
| <a name="input_network_topology_details"></a> [network\_topology\_details](#input\_network\_topology\_details) | Network Details for the environment | <pre>object({<br/>    network_type                  = optional(string, "")<br/>    create_gateways               = optional(bool, false)<br/>    create_vwan                   = optional(bool, false)<br/>    hub_peering_enabled           = optional(bool, true)<br/>    hub_id                        = optional(map(string), {})<br/>    virtual_wan_hubs              = optional(map(any), {})<br/>    bastion_subnet_address_spaces = optional(list(string), [])<br/>  })</pre> | <pre>{<br/>  "bastion_subnet_address_spaces": [],<br/>  "create_gateways": false,<br/>  "create_vwan": false,<br/>  "hub_id": {},<br/>  "network_type": "",<br/>  "virtual_wan_hubs": {}<br/>}</pre> | no |
| <a name="input_org_abbreviation"></a> [org\_abbreviation](#input\_org\_abbreviation) | Organization or company abbreviation used in the ORG placeholder (e.g., 'contoso', 'acme', 'fabrikam'). Helps identify resources belonging to your organization. | `string` | n/a | yes |
| <a name="input_resource_groups"></a> [resource\_groups](#input\_resource\_groups) | Map of already provisioned Resource Groups for use to create Network Hub connectivity resources within. | <pre>map(object({<br/>    resource_name = string<br/>    location      = string<br/>    resource_id   = string<br/>  }))</pre> | n/a | yes |
| <a name="input_resources"></a> [resources](#input\_resources) | Map of Resource Objects to create for naming and reference | <pre>map(object({<br/>    resource_type           = string<br/>    resource_name           = string<br/>    resource_name_overwrite = optional(bool, false)<br/><br/>    resource_group_name           = optional(string, "")<br/>    resource_group_name_overwrite = optional(bool, false)<br/><br/>    location    = optional(string, null)<br/>    structure   = optional(string, null)<br/>    environment = optional(string, null)<br/>    archetype   = optional(string, null)<br/>    existing    = optional(bool, false)<br/>    case_option = optional(string, null)<br/>  }))</pre> | `{}` | no |
| <a name="input_structure"></a> [structure](#input\_structure) | Naming structure pattern using placeholders: ORG, REGION, ENV, PURPOSE, ARCH, TYPE, NAME. Example: 'TYPE-ORG-REGION-ENV-ARCH-NAME' produces 'vm-contoso-uks-prod-web-app01'. | `string` | n/a | yes |
| <a name="input_templated_locations"></a> [templated\_locations](#input\_templated\_locations) | List of locations to deploy templated resources to | `list(string)` | `[]` | no |
| <a name="input_virtual_network_gateways"></a> [virtual\_network\_gateways](#input\_virtual\_network\_gateways) | n/a | `map(any)` | `{}` | no |
| <a name="input_virtual_networks"></a> [virtual\_networks](#input\_virtual\_networks) | Map of already provisioned Virtual Networks for use to create Network Hub connectivity resources within - and also to create the peering connections between the hub and spoke networks that MAY well be in the same archetype as the Connectivity | <pre>map(object({<br/>    resource_name = string<br/>    location      = string<br/>    resource_id   = string<br/>  }))</pre> | `{}` | no |
| <a name="input_virtual_wans"></a> [virtual\_wans](#input\_virtual\_wans) | Map of virtual WANs for connectivity | `map(any)` | `{}` | no |
| <a name="input_workload_abbreviation"></a> [workload\_abbreviation](#input\_workload\_abbreviation) | Workload abbreviation used in the ARCH placeholder (e.g., 'web', 'db', 'api'). Helps identify the purpose of the resource. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_virtual_wan_hub_resource_names"></a> [virtual\_wan\_hub\_resource\_names](#output\_virtual\_wan\_hub\_resource\_names) | n/a |
| <a name="output_virtual_wan_hubs"></a> [virtual\_wan\_hubs](#output\_virtual\_wan\_hubs) | n/a |
| <a name="output_virtual_wan_resource_ids"></a> [virtual\_wan\_resource\_ids](#output\_virtual\_wan\_resource\_ids) | n/a |
<!-- END_TF_DOCS -->

## Maintainer

Phoenix Software
