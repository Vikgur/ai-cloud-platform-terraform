resource "aws_organizations_policy" "limit_ec2" {
  name = "limit-ec2-count"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Deny"
        Action = "ec2:RunInstances"
        Resource = "*"
        Condition = {
          NumericGreaterThanEquals = {
            "ec2:InstanceCount": "60"
          }
        }
      }
    ]
  })
}

resource "aws_organizations_policy_attachment" "attach_guardrails" {
  policy_id = aws_organizations_policy.deny_public_s3.id
  target_id = "ou-xxxx-yyyy"
}
