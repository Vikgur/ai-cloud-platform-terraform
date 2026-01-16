module "iam" {
  source = "./iam"
}

module "oidc" {
  source = "./oidc"
}

module "rbac" {
  source = "./rbac"
}
