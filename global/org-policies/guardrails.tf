resource "aws_organizations_policy" "deny_public_s3" {
  name        = "deny-public-s3"
  description = "Deny public S3 buckets"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Deny"
        Action = [
          "s3:PutBucketAcl",
          "s3:PutBucketPolicy"
        ]
        Resource = "*"
        Condition = {
          Bool = {
            "aws:SecureTransport": "false"
          }
        }
      }
    ]
  })
}

resource "aws_organizations_policy" "deny_unencrypted_ebs" {
  name = "deny-unencrypted-ebs"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Deny"
        Action = "ec2:RunInstances"
        Resource = "*"
        Condition = {
          Bool = {
            "ec2:Encrypted": "false"
          }
        }
      }
    ]
  })
}

resource "aws_organizations_policy" "deny_unsupported_regions" {
  name = "deny-unsupported-regions"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Deny"
        Action = "*"
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "aws:RequestedRegion": [
              "eu-central-1",
              "me-central-1"
            ]
          }
        }
      }
    ]
  })
}

