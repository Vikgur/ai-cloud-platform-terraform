output "training_namespace" {
  value = kubernetes_namespace.training.metadata[0].name
}
