resource "aws_eks_node_group" "ai_cpu" {
  cluster_name    = var.cluster_name
  node_group_name = "ai-cpu"

  instance_types = var.cpu_instance_types

  labels = {
    workload = "ai-cpu"
  }

  scaling_config {
    desired_size = var.cpu_desired
    max_size     = var.cpu_max
    min_size     = var.cpu_min
  }
}
