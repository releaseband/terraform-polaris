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
  repository  = "https://charts.fairwinds.com/stable"
  version     = var.polaris_helm_chart_version
  chart       = "polaris"
  timeout     = 180
  max_history = 10
  values      = var.polaris_helm_chart_values
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
    egress {
      to {
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
