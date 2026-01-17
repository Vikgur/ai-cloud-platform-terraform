variable "cluster_name" {
  type = string
}

variable "gpu_launch_template_id" {
  type = string
}

variable "gpu_desired" { type = number }
variable "gpu_min"     { type = number }
variable "gpu_max"     { type = number }

variable "cpu_instance_types" {
  type = list(string)
}

variable "cpu_desired" { type = number }
variable "cpu_min"     { type = number }
variable "cpu_max"     { type = number }
