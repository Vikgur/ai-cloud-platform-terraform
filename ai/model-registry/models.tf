resource "aws_s3_bucket" "models" {
  bucket = var.bucket_name

  force_destroy = false
}
