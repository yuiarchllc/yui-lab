# IAM Role for Bedrock Agent
# This role allows Bedrock Agent to access required AWS services

# IAM Role for Agent
resource "aws_iam_role" "agent_role" {
  name = local.agent_role_name

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
            "aws:SourceArn" = "arn:aws:bedrock:${var.aws_region}:${data.aws_caller_identity.current.account_id}:agent/*"
          }
        }
      }
    ]
  })

  tags = local.common_tags
}

# IAM Policy Document for Agent
data "aws_iam_policy_document" "agent_policy" {
  # Bedrock LLM model invocation permission
  statement {
    effect = "Allow"
    actions = [
      "bedrock:InvokeModel"
    ]
    resources = [
      local.llm_model_arn
    ]
  }

  # Knowledge Base operations permission
  statement {
    effect = "Allow"
    actions = [
      "bedrock:Retrieve",
      "bedrock:RetrieveAndGenerate"
    ]
    resources = [
      aws_bedrockagent_knowledge_base.rag_kb.arn
    ]
  }
}

# IAM Policy for Agent
resource "aws_iam_policy" "agent_policy" {
  name        = "${local.agent_role_name}-policy"
  description = "Policy for Bedrock Agent to access LLM models and Knowledge Base"
  policy      = data.aws_iam_policy_document.agent_policy.json

  tags = local.common_tags
}

# Attach Policy to Agent Role
resource "aws_iam_role_policy_attachment" "agent_policy_attachment" {
  role       = aws_iam_role.agent_role.name
  policy_arn = aws_iam_policy.agent_policy.arn
}
