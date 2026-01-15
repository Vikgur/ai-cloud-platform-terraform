resource "aws_iam_policy" "terraform_base" {
  name = "terraform-base-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:*",
          "elasticloadbalancing:*",
          "autoscaling:*",
          "iam:PassRole",
          "iam:GetRole",
          "iam:CreateRole",
          "iam:AttachRolePolicy",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:DetachRolePolicy",
          "iam:DeleteRole",
          "kms:*",
          "s3:*",
          "dynamodb:*",
          "logs:*",
          "cloudwatch:*"
        ]
        Resource = "*"
      }
    ]
  })
}
