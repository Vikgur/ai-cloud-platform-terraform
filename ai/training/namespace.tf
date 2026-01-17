resource "kubernetes_namespace" "training" {
  metadata {
    name = var.namespace

    labels = {
      purpose     = "ai-training"
      environment = var.environment
    }
  }
}
