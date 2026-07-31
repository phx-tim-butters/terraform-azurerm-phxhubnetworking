variable "resources" {
  type = map(object({
    resource_type           = string
    resource_name           = string
    resource_name_overwrite = optional(bool, false)

    resource_group_name           = optional(string, "")
    resource_group_name_overwrite = optional(bool, false)

    location    = optional(string, null)
    structure   = optional(string, null)
    environment = optional(string, null)
    archetype   = optional(string, null)
    existing    = optional(bool, false)
    case_option = optional(string, null)
  }))
  description = "Map of Resource Objects to create for naming and reference"
  default     = {}
}

variable "structure" {
  type        = string
  description = "Naming structure pattern using placeholders: ORG, REGION, ENV, PURPOSE, ARCH, TYPE, NAME. Example: 'TYPE-ORG-REGION-ENV-ARCH-NAME' produces 'vm-contoso-uks-prod-web-app01'."
}

variable "environment" {
  type        = string
  description = "Environment identifier used in the ENV placeholder (e.g., 'prod', 'dev', 'test', 'uat', 'nonprod'). Optional, leave empty if not using ENV in your structure."
  default     = ""
}

variable "deploy_abbreviation" {
  type        = string
  default     = ""
  description = "Deployment-specific suffix appended to the end of the resource name (e.g., '001', 'blue', 'green'). Useful for blue-green deployments or numbered instances. Optional."
}

variable "org_abbreviation" {
  type        = string
  description = "Organization or company abbreviation used in the ORG placeholder (e.g., 'contoso', 'acme', 'fabrikam'). Helps identify resources belonging to your organization."
}

variable "archetype" {
  type        = string
  description = "Archetype or workload type used in the ARCH placeholder (e.g., 'web', 'db', 'api'). Helps identify the purpose of the resource."
  default     = ""
}

variable "workload_abbreviation" {
  type        = string
  description = "Workload abbreviation used in the ARCH placeholder (e.g., 'web', 'db', 'api'). Helps identify the purpose of the resource."
  default     = ""
}
