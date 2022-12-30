resource "kubernetes_network_policy" "deny-all" {
  metadata {
    name      = "deny-all"
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }

  spec {
    pod_selector {}
    policy_types = ["Ingress", "Egress"]
  }
}


resource "kubernetes_network_policy" "allow-dns-https" {
  metadata {
    name      = "allow-dns"
    namespace = kubernetes_namespace.namespace.metadata[0].name
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
    namespace = kubernetes_namespace.namespace.metadata[0].name
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
    namespace = kubernetes_namespace.namespace.metadata[0].name
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
    namespace = kubernetes_namespace.namespace.metadata[0].name
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
      from {
        namespace_selector {
          match_labels = {
            name = "linkerd-viz"
          }
        }
        pod_selector {
          match_labels = {
            component = "prometheus"
          }
        }
      }
    }
    policy_types = ["Egress", "Ingress"]
  }
}
