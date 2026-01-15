locals {
  is_prod = var.env == "prod"

  az_count = local.is_prod ? 3 : 2

  default_instance_type = local.is_prod ? "m6i.large" : "t3.medium"
}
