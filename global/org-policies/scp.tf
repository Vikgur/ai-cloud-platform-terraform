resource "aws_organizations_policy" "security_guardrails" {
  name = "org-security-guardrails"
  type = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyDisableCloudTrail"
        Effect = "Deny"
        Action = [
          "cloudtrail:StopLogging",
          "cloudtrail:DeleteTrail"
        ]
        Resource = "*"
      },
      {
        Sid    = "DenyUnencryptedVolumes"
        Effect = "Deny"
        Action = "ec2:CreateVolume"
        Resource = "*"
        Condition = {
          Bool = {
            "ec2:Encrypted" = "false"
          }
        }
      }
    ]
  })
}
