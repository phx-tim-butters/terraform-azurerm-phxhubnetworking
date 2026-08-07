# Phoenix Software - Azure Terraform Connectivity Hub Networking Module

Terraform module for deploying Azure hub networking using a single, consistent entry point.

The module supports two mutually exclusive connectivity models:

- `Vnet-gw`: Virtual Network Gateway-based hub-and-spoke connectivity
- `Vwan`: Virtual WAN and Virtual Hub-based connectivity

It composes Azure Verified Modules (AVM) for implementation and uses the Phoenix naming module for consistent resource naming.

## Intent

Provide a production-focused hub networking module that standardizes how teams deploy and operate core connectivity patterns in Azure.

This module is intended to:

- Offer one interface for two enterprise hub patterns (`Vnet-gw` or `Vwan`)
- Keep naming and structure consistent across environments
- Reuse maintained AVM building blocks instead of custom low-level resource code
- Support optional generation and secure storage of VPN PSKs in Azure Key Vault
- Enable hub-to-spoke connectivity through peering or Virtual WAN hub connections

## Principles

- Single topology per deployment: choose either `Vnet-gw` or `Vwan`
- Convention over variation: naming and key patterns are expected and enforced by input shape
- Secure by design: optionally generate PSKs and store them in Key Vault
- Composable inputs: consume pre-provisioned resource groups and virtual networks
- Operational clarity: expose key Virtual WAN outputs for downstream modules and operations

## Terraform Documentation (TFDocs)

<!-- BEGIN_TF_DOCS -->
<!-- TFDocs content is generated automatically. -->
<!-- END_TF_DOCS -->

## Maintainer

Phoenix Software
