resource "aws_s3_bucket" "logs" {
  bucket = "company-${var.environment}-logs"

  force_destroy = false
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
