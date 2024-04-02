variable "vault_token" {
  description = "Token for vault provider"
  type        = string
}


variable "domain_name" {
  description = "Domain for vault provider"
  type        = string
}

variable "polaris_helm_chart_version" {
  type        = string
  default     = "5.4.2"
  description = "polaris helm chart version"
}

variable "polaris_helm_chart_values" {
  default     = ""
  description = "values for polaris helm chart"
}

variable "dashboard_resources" {
  type = map(any)
  description = "dashboard resources"
}

variable "webhook_resources" {
  type = map(any)
  description = "webhook resources"
}