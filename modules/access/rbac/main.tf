resource "kubernetes_cluster_role" "readonly" {
  metadata {
    name = "readonly"
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "services"]
    verbs      = ["get", "list", "watch"]
  }
}
