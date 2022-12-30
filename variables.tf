variable "vault_token" {
  description = "Token for vault provider"
  type        = string
}

variable "wait_vault" {
  description = "Variable for module order"
  type        = string
}

variable "domain_name" {
  description = "Domain for vault provider"
  type        = string
}

variable "allowed_container_registry" {
  description = "Pattern for allowed container registry"
  default     = ".*"
  type        = string
}


variable "polaris_image_repository" {
  default     = "quay.io/fairwinds/polaris"
  description = "polaris image repository"
  type        = string
}

variable "polaris_image_tag" {
  default     = "7.0.2"
  description = "polaris image tag"
  type        = string
}
