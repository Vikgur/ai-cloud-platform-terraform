resource "kubernetes_network_policy" "training_restricted" {
  metadata {
    name      = "training-restricted-egress"
    namespace = kubernetes_namespace.training.metadata[0].name
  }

  spec {
    pod_selector {}

    policy_types = ["Egress"]

    egress {}
  }
}
