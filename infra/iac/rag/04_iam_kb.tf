# IAM Role for Knowledge Base
# This role allows Bedrock Knowledge Base to access required AWS services

# IAM Role for Knowledge Base
resource "aws_iam_role" "kb_role" {
  name = local.kb_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "bedrock.amazonaws.com"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
          StringLike = {
            "aws:SourceArn" = "arn:aws:bedrock:${var.aws_region}:${data.aws_caller_identity.current.account_id}:knowledge-base/*"
          }
        }
      }
    ]
  })

  tags = local.common_tags
}

# IAM Policy Document for Knowledge Base permissions
data "aws_iam_policy_document" "kb_policy" {
  # Permission to invoke Bedrock embedding model
  statement {
    effect = "Allow"
    actions = [
      "bedrock:InvokeModel"
    ]
    resources = [
      local.embedding_model_arn
    ]
  }

  # Permission to invoke Bedrock foundation model for parsing (OCR)
  statement {
    effect = "Allow"
    actions = [
      "bedrock:InvokeModel"
    ]
    resources = [
      "arn:aws:bedrock:${var.aws_region}::foundation-model/anthropic.claude-3-sonnet-20240229-v1:0"
    ]
  }

  # Permission to invoke Bedrock Data Automation for OCR processing
  statement {
    effect = "Allow"
    actions = [
      "bedrock:InvokeDataAutomationAsync",
      "bedrock:GetDataAutomationStatus"
    ]
    resources = [
      "arn:aws:bedrock:*:aws:data-automation-project/public-rag-default",
      "arn:aws:bedrock:*:${data.aws_caller_identity.current.account_id}:data-automation-profile/*",
      "arn:aws:bedrock:*:${data.aws_caller_identity.current.account_id}:data-automation-invocation/*"
    ]
  }

  # Permissions for S3 Vectors operations
  statement {
    effect = "Allow"
    actions = [
      "s3vectors:GetIndex",
      "s3vectors:QueryVectors",
      "s3vectors:PutVectors",
      "s3vectors:GetVectors",
      "s3vectors:DeleteVectors"
    ]
    resources = [
      aws_s3vectors_index.rag_index.index_arn
    ]
  }

  # Permissions for S3 Data Source read operations
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.data_source.arn,
      "${aws_s3_bucket.data_source.arn}/*"
    ]
  }
}

# IAM Policy resource
resource "aws_iam_policy" "kb_policy" {
  name        = "${local.kb_role_name}-policy"
  description = "Policy for Knowledge Base to access Bedrock models, S3 Vectors, and Data Source bucket"
  policy      = data.aws_iam_policy_document.kb_policy.json

  tags = local.common_tags
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "kb_policy_attachment" {
  role       = aws_iam_role.kb_role.name
  policy_arn = aws_iam_policy.kb_policy.arn
}
