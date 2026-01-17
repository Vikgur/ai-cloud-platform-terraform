resource "kubernetes_resource_quota" "training" {
  metadata {
    name      = "training-quota"
    namespace = kubernetes_namespace.training.metadata[0].name
  }

  spec {
    hard = {
      "limits.cpu"              = var.cpu_limit
      "limits.memory"           = var.memory_limit
      "requests.nvidia.com/gpu" = var.gpu_limit
    }
  }
}
