resource "aws_s3_bucket" "this" {
  bucket        = local.s3.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "this" {
  bucket     = aws_s3_bucket.this.id
  acl        = "private"
  depends_on = [aws_s3_bucket_ownership_controls.this]
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontAccess"
        Effect = "Allow"
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.this.iam_arn
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.this.arn}/*"
      },
      {
        Sid    = "AllowCloudFrontLogging"
        Effect = "Allow"
        Principal = {
          Service = "logging.s3.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.this.arn}/access_log/*"
      }
    ]
  })
  depends_on = [aws_s3_bucket_acl.this]
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_object" "this" {
  for_each         = fileset(path.module, "${local.s3.statics_dir}**/*")
  bucket           = local.s3.bucket_name
  key              = "statics${replace(each.value, "${local.s3.statics_dir}", "")}"
  source           = each.value
  content_type     = lookup(local.s3.content_types, element(split(".", each.value), length(split(".", each.value)) - 1), "text/plain")
  content_encoding = "utf-8"
  etag             = filemd5("${each.value}")
  depends_on       = [aws_s3_bucket.this]
}