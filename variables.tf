variable "vault_token" {
  description = "Token for vault provider"
  type        = string
}


variable "domain_name" {
  description = "Domain for vault provider"
  type        = string
}
variable "eks_cluster_name" {
  type = string
  default = "Cluster name"
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
  type        = map(any)
  description = "dashboard resources"
}

variable "webhook_resources" {
  type        = map(any)
  description = "webhook resources"
}

# OAUTH2
variable "oauth2_proxy_allowed_group" {
  type = string
}
variable "oauth2_proxy_resources" {
  type = map(any)
}
variable "oauth2_proxy_required_resource_access_MicrosoftGraph" {
  type = string
  default = "00000003-0000-0000-c000-000000000000"
}
variable "oauth2_proxy_resource_access_GroupReadAll" {
  type = string
  default = "5f8c59db-677d-491f-a6b8-5f174b11ec1d"
}
variable "oauth2_proxy_resource_access_DirectoryReadAll" {
  type = string
  default = "06da0dbc-49e2-44d2-8312-53f166ab848a"
}