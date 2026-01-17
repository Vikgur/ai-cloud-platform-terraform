resource "aws_eks_node_group" "gpu" {
  cluster_name    = var.cluster_name
  node_group_name = "ai-gpu"

  launch_template {
    id      = var.gpu_launch_template_id
    version = "$Latest"
  }

  labels = {
    workload = "ai-gpu"
  }

  taints {
    key    = "ai"
    value  = "gpu"
    effect = "NO_SCHEDULE"
  }

  scaling_config {
    desired_size = var.gpu_desired
    max_size     = var.gpu_max
    min_size     = var.gpu_min
  }
}
