output "terraform_role_arn" {
  value = module.iam.terraform_role_arn
}

output "oidc_provider_arn" {
  value = module.oidc.provider_arn
}
