resource "kubernetes_namespace" "namespace" {
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