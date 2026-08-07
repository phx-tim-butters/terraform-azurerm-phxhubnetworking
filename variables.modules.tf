variable "module_phx_naming_version" {
  description = "The version of the naming module to use."
  type        = string
  const       = true
  default     = "0.1.7"
}

variable "module_avm_res_network_virtualnetwork_version" {
  description = "The version of the Azure/avm-res-network-virtualnetwork module to use."
  type        = string
  const       = true
  default     = "0.14.1"
}

variable "module_avm_ptn_alz_connectivity_hub_and_spoke_vnet_version" {
  description = "The version of the Azure/avm-ptn-alz-connectivity-hub-and-spoke-vnet module to use."
  type        = string
  const       = true
  default     = "0.17.3"
}

variable "module_avm_ptn_alz_connectivity_virtual_wan_version" {
  description = "The version of the Azure/avm-ptn-alz-connectivity-virtual-wan module to use."
  type        = string
  const       = true
  default     = "0.16.1"
}
