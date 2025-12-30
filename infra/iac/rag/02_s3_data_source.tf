# S3 Data Source Bucket for RAG system
# This bucket stores source documents that will be processed by Knowledge Base

resource "aws_s3_bucket" "data_source" {
  bucket        = local.data_source_bucket_name
  force_destroy = true

  tags = local.common_tags
}

# Enable versioning for the data source bucket
resource "aws_s3_bucket_versioning" "data_source" {
  bucket = aws_s3_bucket.data_source.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Configure server-side encryption with AES256
resource "aws_s3_bucket_server_side_encryption_configuration" "data_source" {
  bucket = aws_s3_bucket.data_source.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block all public access to the bucket
resource "aws_s3_bucket_public_access_block" "data_source" {
  bucket = aws_s3_bucket.data_source.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
