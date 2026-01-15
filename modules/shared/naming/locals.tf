locals {
  name_prefix = join("-", [
    var.org,
    var.project,
    var.env
  ])
}
