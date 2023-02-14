<!-- BEGIN_TF_DOCS -->


## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |

## Resources

| Name | Type |
|------|------|
| [helm_release.polaris](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_cluster_role.main](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role) | resource |
| [kubernetes_cluster_role_binding.main](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding) | resource |
| [kubernetes_namespace.main](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_network_policy.allow-dns-https](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/network_policy) | resource |
| [kubernetes_network_policy.deny-all](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/network_policy) | resource |
| [kubernetes_network_policy.linkerd_proxy](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/network_policy) | resource |
| [kubernetes_network_policy.polaris_webhook](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/network_policy) | resource |
| [kubernetes_network_policy.vault](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/network_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Domain for vault provider | `string` | n/a | yes |
| <a name="input_polaris_helm_chart_values"></a> [polaris\_helm\_chart\_values](#input\_polaris\_helm\_chart\_values) | values for polaris helm chart | `string` | `""` | no |
| <a name="input_polaris_helm_chart_version"></a> [polaris\_helm\_chart\_version](#input\_polaris\_helm\_chart\_version) | polaris helm chart version | `string` | `"5.4.2"` | no |
| <a name="input_vault_token"></a> [vault\_token](#input\_vault\_token) | Token for vault provider | `string` | n/a | yes |
| <a name="input_wait_vault"></a> [wait\_vault](#input\_wait\_vault) | Variable for module order | `string` | n/a | yes |
<!-- END_TF_DOCS -->