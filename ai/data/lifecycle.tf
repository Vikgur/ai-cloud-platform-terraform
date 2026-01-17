resource "aws_s3_bucket_lifecycle_configuration" "datasets" {
  bucket = aws_s3_bucket.datasets.id

  rule {
    id     = "retain-datasets"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 365
    }
  }
}
