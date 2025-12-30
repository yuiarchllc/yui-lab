# Bedrock Knowledge Base
# This resource creates a Knowledge Base that integrates with S3 Vectors for document storage and retrieval

resource "aws_bedrockagent_knowledge_base" "rag_kb" {
  name     = local.knowledge_base_name
  role_arn = aws_iam_role.kb_role.arn

  knowledge_base_configuration {
    type = "VECTOR"

    vector_knowledge_base_configuration {
      embedding_model_arn = local.embedding_model_arn

      embedding_model_configuration {
        bedrock_embedding_model_configuration {
          dimensions = local.vector_dimensions
        }
      }
    }
  }

  storage_configuration {
    type = "S3_VECTORS"

    s3_vectors_configuration {
      index_arn = aws_s3vectors_index.rag_index.index_arn
    }
  }

  # Ensure IAM role and policy are fully configured before creating Knowledge Base
  depends_on = [
    aws_iam_role_policy_attachment.kb_policy_attachment
  ]

  tags = local.common_tags
}
# Bedrock Data Source
# This resource connects the S3 bucket to the Knowledge Base for document ingestion

resource "aws_bedrockagent_data_source" "rag_data_source" {
  name              = local.data_source_name
  knowledge_base_id = aws_bedrockagent_knowledge_base.rag_kb.id

  data_source_configuration {
    type = "S3"

    s3_configuration {
      bucket_arn = aws_s3_bucket.data_source.arn
    }
  }

  vector_ingestion_configuration {
    chunking_configuration {
      chunking_strategy = "FIXED_SIZE"
      fixed_size_chunking_configuration {
        max_tokens         = 300
        overlap_percentage = 20
      }
    }

    parsing_configuration {
      parsing_strategy = "BEDROCK_DATA_AUTOMATION"
    }
  }

  # Ensure Knowledge Base is created before Data Source
  depends_on = [aws_bedrockagent_knowledge_base.rag_kb]
}
