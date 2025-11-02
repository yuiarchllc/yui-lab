resource "aws_s3_bucket" "this" {
  bucket        = local.s3.bucket_name
  force_destroy = true
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
  depends_on = [ aws_s3_bucket.this ]
}