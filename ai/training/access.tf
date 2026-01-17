resource "kubernetes_role" "training_runner" {
  metadata {
    name      = "training-runner"
    namespace = kubernetes_namespace.training.metadata[0].name
  }

  rule {
    api_groups = ["batch"]
    resources  = ["jobs"]
    verbs      = ["create", "get", "list", "watch"]
  }
}
