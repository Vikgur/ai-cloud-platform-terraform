output "gpu_node_group" {
  value = aws_eks_node_group.gpu.node_group_name
}

output "cpu_node_group" {
  value = aws_eks_node_group.ai_cpu.node_group_name
}
