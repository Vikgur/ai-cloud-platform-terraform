resource "aws_iam_role_policy_attachment" "terraform_attach" {
  role       = aws_iam_role.terraform.name
  policy_arn = aws_iam_policy.terraform_base.arn
}
