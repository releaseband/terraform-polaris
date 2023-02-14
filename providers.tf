provider "vault" {
  address = "https://vault.${var.domain_name}/"
  token   = var.vault_token
}
