resource "aws_iam_role" "break_glass" {
  name = "break-glass-admin"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::<SECURITY_ACCOUNT_ID>:role/security-incident-response"
        }
        Action = "sts:AssumeRole"
        Condition = {
          Bool = {
            "aws:MultiFactorAuthPresent" = "true"
          }
          StringEquals = {
            "sts:ExternalId" = "break-glass-approved"
          }
        }
      }
    ]
  })

  tags = {
    purpose = "emergency-access"
    owner   = "security"
  }
}

resource "aws_iam_role_policy_attachment" "break_glass_admin" {
  role       = aws_iam_role.break_glass.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
