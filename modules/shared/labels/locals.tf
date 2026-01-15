locals {
  common_labels = {
    app     = var.project
    env     = var.env
    tier    = var.tier
    managed = "terraform"
  }
}
