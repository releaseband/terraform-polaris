resource "kubernetes_cluster_role" "polaris-calico" {
  metadata {
    name = "polaris-calico"
  }

  rule {
    api_groups = [""]
    resources  = ["*"]
    verbs      = ["*"]
  }
}


resource "kubernetes_cluster_role_binding" "polaris-calico" {
  metadata {
    name = "polaris-calico"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "tigera-operator"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "polaris"
    namespace = kubernetes_namespace.namespace.metadata[0].name
  }
}