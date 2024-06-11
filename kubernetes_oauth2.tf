
# # Configure  Oauth2 Azure Application secrets and deploy service oauth2
# resource "kubernetes_deployment_v1" "oauth2" {
#   depends_on = [vault_generic_secret.oauth2_proxy]
#   metadata {
#     name      = local.appname
#     namespace = kubernetes_namespace.main.metadata[0].name
#     labels = {
#       app                           = "polaris"
#       "app.kubernetes.io/component" = "oauth2-proxy"

#     }
#   }
#   spec {
#     selector {
#       match_labels = {
#         "app.kubernetes.io/component" = "oauth2-proxy"
#       }
#     }
#     template {
#       metadata {
#         labels = {
#           app                           = "polaris"
#           "app.kubernetes.io/component" = "oauth2-proxy"
#         }
#         annotations = {
#           "vault.hashicorp.com/agent-inject"                 = "true"
#           "vault.hashicorp.com/agent-init-first"             = "true"
#           "vault.hashicorp.com/agent-inject-secret-oauth2"   = "secrets/polaris/oauth2-proxy-config"
#           "vault.hashicorp.com/agent-limits-cpu"             = 0.05
#           "vault.hashicorp.com/agent-requests-cpu"           = 0.01
#           "vault.hashicorp.com/agent-pre-populate-only"      = "true"
#           "vault.hashicorp.com/role"                         = vault_kubernetes_auth_backend_role.main.role_name
#           "vault.hashicorp.com/agent-inject-template-oauth2" = <<-EOF
#           {{- with secret "secrets/polaris/oauth2-proxy-config" -}}
#           client_id="{{ .Data.oauth2_proxy_client_id }}"
#           client_secret="{{ .Data.oauth2_proxy_client_secret }}"
#           cookie_secret="{{ .Data.oauth2_proxy_cookie_secret }}"
#           scope="openid email profile"
#           cookie_name="_proxycookie"
#           standard_logging="true"
#           auth_logging="true"
#           request_logging="true"
#           http_address="0.0.0.0:4180"
#           {{- end }}
#           EOF
#         }
#       }
#       spec {
#         service_account_name = "polaris"
#         container {
#           name              = local.appname
#           image             = "docker.io/bitnami/oauth2-proxy:7.6.0-debian-12-r12"
#           image_pull_policy = "Always"
#           args = [
#             "--config=/vault/secrets/oauth2",
#             "--provider=azure",
#             "--azure-tenant=${data.azuread_client_config.current.tenant_id}",
#             "--redirect-url=https://polaris.${var.domain_name}/oauth2/callback",
#             "--oidc-issuer-url=https://login.microsoftonline.com/${data.azuread_client_config.current.tenant_id}/v2.0",
#             "--email-domain=*",
#             "--upstream=file:///dev/null",
#             "--allowed-group=${var.oauth2_proxy_allowed_group}",
#             "--azure-graph-group-field=id"
#           ]
#           port {
#             protocol       = "TCP"
#             container_port = 4180
#           }
#           resources {
#             limits = {
#               cpu    = var.oauth2_proxy_resources.limits.cpu
#               memory = var.oauth2_proxy_resources.limits.memory
#             }
#             requests = {
#               cpu    = var.oauth2_proxy_resources.requests.cpu
#               memory = var.oauth2_proxy_resources.requests.memory
#             }
#           }

#           security_context {
#             allow_privilege_escalation = false
#             privileged                 = false
#             read_only_root_filesystem  = true
#             run_as_non_root            = true
#             run_as_user                = 1001
#             capabilities {
#               drop = ["ALL"]
#             }
#           }
#         }
#       }
#     }
#   }
# }
# resource "kubernetes_service" "oauth2" {
#   metadata {
#     name      = local.appname
#     namespace = kubernetes_namespace.main.metadata[0].name
#   }
#   spec {
#     port {
#       name        = "http"
#       protocol    = "TCP"
#       port        = 4180
#       target_port = 4180
#     }
#     selector = {
#       "app.kubernetes.io/component" = "oauth2-proxy"
#     }
#   }
# }
# resource "kubernetes_ingress_v1" "oauth2" {
#   metadata {
#     name      = local.appname
#     namespace = kubernetes_namespace.main.metadata[0].name
#     annotations = {
#       "nginx.ingress.kubernetes.io/affinity"               = "cookie"
#       "nginx.ingress.kubernetes.io/proxy-body-size"        = "2000m"
#       "nginx.ingress.kubernetes.io/proxy-buffer-size"      = "32k"
#       "nginx.ingress.kubernetes.io/proxy-buffers-number"   = "4"
#       "nginx.ingress.kubernetes.io/server-snippet"         = <<-EOF
#             client_header_buffer_size 32k;
#             large_client_header_buffers 8 32k;
#         EOF
#       "nginx.ingress.kubernetes.io/session-cookie-expires" = "172800"
#       "nginx.ingress.kubernetes.io/session-cookie-max-age" = "172800"
#       "nginx.ingress.kubernetes.io/session-cookie-hash"    = "sha1"
#       "nginx.ingress.kubernetes.io/session-cookie-name"    = "_proxycookie"
#       "nginx.ingress.kubernetes.io/ssl-redirect"           = "false"
#       "nginx.ingress.kubernetes.io/upstream-vhost"         = "${local.appname}.${kubernetes_namespace.main.metadata[0].name}.svc.cluster.local:4180"
#     }
#   }
#   spec {
#     ingress_class_name = "global"
#     rule {
#       host = "polaris.${var.domain_name}"
#       http {
#         path {
#           path      = "/oauth2"
#           path_type = "Prefix"
#           backend {
#             service {
#               name = local.appname
#               port {
#                 number = 4180
#               }
#             }
#           }
#         }
#       }
#     }
#   }
# }
# resource "kubernetes_network_policy" "polaris-oauth2" {
#   metadata {
#     name      = "polaris-oauth2"
#     namespace = kubernetes_namespace.main.metadata[0].name
#   }

#   spec {
#     pod_selector {
#       match_labels = {
#         "app.kubernetes.io/component" = "oauth2-proxy"
#       }
#     }
#     ingress {
#       ports {
#         port     = "4180"
#         protocol = "TCP"
#       }
#       ports {
#         port     = 8200
#         protocol = "TCP"
#       }
#       from {
#         namespace_selector {}
#         pod_selector {
#           match_labels = {
#             "app.kubernetes.io/name" = "ingress-nginx"
#           }
#         }
#       }
#     }
#     policy_types = ["Ingress"]
#   }
# }
