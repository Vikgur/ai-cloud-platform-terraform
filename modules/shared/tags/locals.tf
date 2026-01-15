locals {
  common_tags = {
    Organization = var.org
    Project      = var.project
    Environment  = var.env
    ManagedBy    = "terraform"
    Owner        = var.owner
    CostCenter   = var.cost_center
  }
}
