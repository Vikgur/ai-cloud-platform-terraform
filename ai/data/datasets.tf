resource "aws_s3_bucket" "datasets" {
  bucket = var.bucket_name

  force_destroy = false
}
