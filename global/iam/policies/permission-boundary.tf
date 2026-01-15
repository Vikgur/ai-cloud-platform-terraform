resource "aws_iam_policy" "terraform_boundary" {
  name        = "terraform-permission-boundary"
  description = "Maximum allowed permissions for Terraform roles"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [

      # ---- ALLOW: infrastructure ----
      {
        Effect = "Allow"
        Action = [
          "ec2:*",
          "elasticloadbalancing:*",
          "autoscaling:*",
          "eks:*",
          "vpc:*",
          "s3:*",
          "logs:*",
          "cloudwatch:*"
        ]
        Resource = "*"
      },

      # ---- ALLOW: minimum IAM ----
      {
        Effect = "Allow"
        Action = [
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:GetRole",
          "iam:UpdateRole",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:PassRole"
        ]
        Resource = "*"
      },

      # ---- DENY: IAM escalation ----
      {
        Effect = "Deny"
        Action = [
          "iam:CreateUser",
          "iam:DeleteUser",
          "iam:PutUserPolicy",
          "iam:PutRolePolicy",
          "iam:CreatePolicy",
          "iam:DeletePolicy",
          "iam:SetDefaultPolicyVersion",
          "iam:AttachUserPolicy",
          "iam:DetachUserPolicy"
        ]
        Resource = "*"
      },

      # ---- DENY: platform control ----
      {
        Effect = "Deny"
        Action = [
          "organizations:*",
          "account:*"
        ]
        Resource = "*"
      }
    ]
  })
}
