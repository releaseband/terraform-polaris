provider "vault" {
  address = "https://vault.${var.domain_name}/"
  token   = var.vault_token
}

terraform {
  required_version = ">= 1.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.16"
    }
    vault = {
      source  = "hashicorp/vault"
      version = ">= 3.11"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.8"
    }
  }
}