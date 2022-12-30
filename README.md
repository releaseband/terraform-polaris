<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | 1.3.6 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 2.8.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.16.1 |
| <a name="requirement_vault"></a> [vault](#requirement\_vault) | 3.11.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.8.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.16.1 |

## Resources

| Name | Type |
|------|------|
| [helm_release.polaris](https://registry.terraform.io/providers/hashicorp/helm/2.8.0/docs/resources/release) | resource |
| [kubernetes_cluster_role.polaris-calico](https://registry.terraform.io/providers/hashicorp/kubernetes/2.16.1/docs/resources/cluster_role) | resource |
| [kubernetes_cluster_role_binding.polaris-calico](https://registry.terraform.io/providers/hashicorp/kubernetes/2.16.1/docs/resources/cluster_role_binding) | resource |
| [kubernetes_namespace.namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/2.16.1/docs/resources/namespace) | resource |
| [kubernetes_network_policy.allow-dns-https](https://registry.terraform.io/providers/hashicorp/kubernetes/2.16.1/docs/resources/network_policy) | resource |
| [kubernetes_network_policy.deny-all](https://registry.terraform.io/providers/hashicorp/kubernetes/2.16.1/docs/resources/network_policy) | resource |
| [kubernetes_network_policy.linkerd_proxy](https://registry.terraform.io/providers/hashicorp/kubernetes/2.16.1/docs/resources/network_policy) | resource |
| [kubernetes_network_policy.polaris_webhook](https://registry.terraform.io/providers/hashicorp/kubernetes/2.16.1/docs/resources/network_policy) | resource |
| [kubernetes_network_policy.vault](https://registry.terraform.io/providers/hashicorp/kubernetes/2.16.1/docs/resources/network_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_container_registry"></a> [allowed\_container\_registry](#input\_allowed\_container\_registry) | Pattern for allowed container registry | `string` | `".*"` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Domain for vault provider | `string` | n/a | yes |
| <a name="input_polaris_image_repository"></a> [polaris\_image\_repository](#input\_polaris\_image\_repository) | polaris image repository | `string` | `"quay.io/fairwinds/polaris"` | no |
| <a name="input_polaris_image_tag"></a> [polaris\_image\_tag](#input\_polaris\_image\_tag) | polaris image tag | `string` | `"7.0.2"` | no |
| <a name="input_vault_token"></a> [vault\_token](#input\_vault\_token) | Token for vault provider | `string` | n/a | yes |
| <a name="input_wait_vault"></a> [wait\_vault](#input\_wait\_vault) | Variable for module order | `string` | n/a | yes |
<!-- END_TF_DOCS -->