# locals {
#   appname                    = "polaris-oauth2-proxy"
#   azure_appname              = "polaris-oauth2-${var.eks_cluster_name}"
#   oauth2_proxy_cookie_secret = "2HbbTskSPJ1nU0Tl5sbbfAyOGLQJ4uDLHur2q9TEDQM=" # it's random openssl rand -base64 32
#   redirectUrl                = "https://polaris.${var.domain_name}/oauth2/callback"
# }
resource "kubernetes_cluster_role" "main" {
  metadata {
    name = "polaris-calico"
  }

  rule {
    api_groups = [""]
    resources  = ["*"]
    verbs      = ["*"]
  }
}


resource "kubernetes_cluster_role_binding" "main" {
  metadata {
    name = "polaris-calico"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.main.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = "polaris"
    namespace = kubernetes_namespace.main.metadata[0].name
  }
}

resource "kubernetes_namespace" "main" {
  metadata {
    labels = {
      name = "polaris"
    }
    name = "polaris"
    annotations = {
      "linkerd.io/inject"                  = "enabled"
      "config.linkerd.io/proxy-await"      = "enabled"
      "config.linkerd.io/proxy-log-format" = "json"
    }
  }
}


resource "helm_release" "polaris" {
  name        = "polaris"
  namespace   = kubernetes_namespace.main.metadata[0].name
  repository  = "https://nexus.releaseband.com/repository/helm-proxy-polaris/"
  version     = var.polaris_helm_chart_version
  chart       = "polaris"
  timeout     = 180
  max_history = 10
  postrender {
    binary_path = "${path.module}/kustomize/kustomize.sh"
  }
  values = var.polaris_helm_chart_values
  set {
    name  = "dashboard.resources.limits.cpu"
    value = var.dashboard_resources.limits.cpu
  }
  set {
    name  = "dashboard.resources.limits.memory"
    value = var.dashboard_resources.limits.memory
  }
  set {
    name  = "dashboard.resources.requests.cpu"
    value = var.dashboard_resources.requests.cpu
  }
  set {
    name  = "dashboard.resources.requests.memory"
    value = var.dashboard_resources.requests.memory
  }
  set {
    name  = "webhook.resources.limits.cpu"
    value = var.webhook_resources.limits.cpu
  }
  set {
    name  = "webhook.resources.limits.memory"
    value = var.webhook_resources.limits.memory
  }
  set {
    name  = "webhook.resources.requests.cpu"
    value = var.webhook_resources.requests.cpu
  }
  set {
    name  = "webhook.resources.requests.memory"
    value = var.webhook_resources.requests.memory
  }
}

resource "kubernetes_network_policy" "deny-all" {
  metadata {
    name      = "deny-all"
    namespace = kubernetes_namespace.main.metadata[0].name
  }

  spec {
    pod_selector {}
    policy_types = ["Ingress", "Egress"]
  }
}


resource "kubernetes_network_policy" "allow-dns-https" {
  metadata {
    name      = "allow-dns"
    namespace = kubernetes_namespace.main.metadata[0].name
  }

  spec {
    pod_selector {}
    egress {
      ports {
        port     = "53"
        protocol = "TCP"
      }
      ports {
        port     = "53"
        protocol = "UDP"
      }
      ports {
        port     = "443"
        protocol = "TCP"
      }
      ports {
        port     = "587"
        protocol = "TCP"
      }
    }
    policy_types = ["Egress"]
  }
}


resource "kubernetes_network_policy" "polaris_webhook" {
  metadata {
    name      = "polaris-webhook"
    namespace = kubernetes_namespace.main.metadata[0].name
  }

  spec {
    pod_selector {
      match_labels = {
        app = "polaris"
      }
    }
    ingress {
      ports {
        port     = "9876"
        protocol = "TCP"
      }
    }
    policy_types = ["Ingress"]
  }
}


resource "kubernetes_network_policy" "vault" {
  metadata {
    name      = "polaris-vault"
    namespace = kubernetes_namespace.main.metadata[0].name
  }

  spec {
    pod_selector {
      match_labels = {
        "app" = "polaris"
      }
    }
    egress {
      ports {
        port     = "8200"
        protocol = "TCP"
      }
      to {
        namespace_selector {
          match_labels = {
            name = "vault"
          }
        }
      }
    }
    policy_types = ["Egress"]
  }
}


resource "kubernetes_network_policy" "polaris_proxy" {
  metadata {
    name      = "polaris-proxy"
    namespace = kubernetes_namespace.main.metadata[0].name
  }

  spec {
    pod_selector {
      match_expressions {
        key      = "polaris.io/workload-ns"
        operator = "Exists"
      }
    }
    egress {
      to {
        namespace_selector {
          match_labels = {
            name = "polaris"
          }
        }
        pod_selector {
          match_expressions {
            key      = "polaris.io/control-plane-component"
            operator = "Exists"
          }
        }
      }
    }
    ingress {
      from {
        namespace_selector {
          match_labels = {
            name = "polaris"
          }
        }
        pod_selector {
          match_expressions {
            key      = "polaris.io/control-plane-component"
            operator = "Exists"
          }
        }
      }
    }
    ingress {
      ports {
        port     = "4191"
        protocol = "TCP"
      }
      from {
        namespace_selector {
          match_labels = {
            name = "monitoring"
          }
        }
        pod_selector {
          match_labels = {
            "app.kubernetes.io/name" = "prometheus"
          }
        }
      }
    }
    policy_types = ["Egress", "Ingress"]
  }
}
resource "kubernetes_network_policy" "linkerd_proxy" {
  metadata {
    name      = "linkerd-proxy"
    namespace = kubernetes_namespace.main.metadata[0].name
  }
  spec {
    pod_selector {
      match_expressions {
        key      = "linkerd.io/workload-ns"
        operator = "Exists"
      }
    }
    ingress {
      from {
        namespace_selector {
          match_labels = {
            name = "linkerd"
          }
        }
        pod_selector {
          match_expressions {
            key      = "linkerd.io/control-plane-component"
            operator = "Exists"
          }
        }
      }
      ports {
        protocol = "TCP"
        port     = "4191"
      }
      from {
        namespace_selector {
          match_labels = {
            name = "monitoring"
          }
        }
        pod_selector {
          match_labels = {
            "app.kubernetes.io/name" = "prometheus"
          }
        }
      }
    }
    egress {
      to {
        pod_selector {
          match_expressions {
            key      = "linkerd.io/control-plane-component"
            operator = "Exists"
          }
        }
        namespace_selector {
          match_labels = {
            name = "linkerd"
          }
        }
      }
    }
    policy_types = ["Egress", "Ingress"]
  }
}
resource "kubernetes_network_policy" "polaris_dashboard" {
  metadata {
    name      = "polaris-dashboard"
    namespace = kubernetes_namespace.main.metadata[0].name
  }
  spec {
    pod_selector {
      match_labels = {
        "app"                         = "polaris"
      }
    }
    ingress {
      ports {
        protocol = "TCP"
        port     = "8080"
      }
      from {
        pod_selector {
          match_labels = {
            "app.kubernetes.io/name" = "ingress-nginx"
          }
        }
        namespace_selector {}
      }
    }
    policy_types = ["Ingress"]
  }
}
resource "vault_kubernetes_auth_backend_role" "main" {
  backend                          = "kubernetes/"
  role_name                        = "polaris"
  bound_service_account_names      = ["polaris"]
  bound_service_account_namespaces = ["polaris"]
  token_ttl                        = 3600
  token_policies                   = ["polaris"]
}
resource "vault_policy" "main" {
  name = "polaris"

  policy = <<EOT
path "secret/data/infrastructure/polaris/*" {
  capabilities = ["read"]
}
EOT
}
data "kubernetes_ingress_v1" "ingress" {
  metadata {
    name      = "ingress-global-alb"
    namespace = "ingress"
  }
}
resource "kubernetes_ingress_v1" "polaris-dashboard" {
  metadata {
    name      = "polaris-dashboard"
    namespace = kubernetes_namespace.main.metadata[0].name
    annotations = {
      "external-dns.alpha.kubernetes.io/target"    = data.kubernetes_ingress_v1.ingress.status.0.load_balancer.0.ingress.0.hostname
      "nginx.ingress.kubernetes.io/auth-signin"    = "https://polaris.releaseband.com/oauth2/sign_in?rd=%2F"
      "nginx.ingress.kubernetes.io/auth-url"       = "http://polaris-oauth2-proxy.polaris.svc.cluster.local:4180/oauth2/auth"
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
      "nginx.ingress.kubernetes.io/ssl-redirect"   = "false"
    }
  }
  spec {
    ingress_class_name = "global"
    rule {
      host = "polaris.${var.domain_name}"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "polaris-dashboard"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
# data "azuread_application" "current" {
#   display_name = local.azure_appname
# }
# data "kubernetes_secret_v1" "oauth2" {
#   metadata {
#     name      = local.appname
#     namespace = kubernetes_namespace.main.metadata[0].name
#   }
# }

# resource "vault_generic_secret" "oauth2_proxy" {
#   path = "secrets/polaris/oauth2-proxy-config"
#   data_json = jsonencode({
#     oauth2_proxy_client_id     = data.azuread_application.current.client_id
#     oauth2_proxy_client_secret = data.kubernetes_secret_v1.oauth2.data["attribute.value"]
#     oauth2_proxy_cookie_secret = local.oauth2_proxy_cookie_secret
#   })
# }